import boto3

iam = boto3.client('iam')


def lambda_handler(event, context):
    account_id = event['account']
    time_discovered = event['time']
    access_key_ids = [entity['entityValue'] for entity in event['detail']['affectedEntities']]
    if not access_key_ids:
        raise ValueError('No affected entities found in event.')

    disabled_keys = []
    failed_keys = []
    # Attempt every key before failing so one bad key does not leave the others active.
    for access_key_id in access_key_ids:
        try:
            print('Looking up username for access key pair "{}"...'.format(access_key_id))
            username = get_username_from_key(access_key_id)
            print('Disabling exposed access key pair "{}"...'.format(access_key_id))
            disable_exposed_key_pair(username, access_key_id)
            disabled_keys.append({"username": username, "access_key_id": access_key_id})
        except Exception:
            failed_keys.append(access_key_id)

    if failed_keys:
        raise RuntimeError('Failed to disable access keys: {}'.format(', '.join(failed_keys)))

    return {
        "account_id": account_id,
        "time_discovered": time_discovered,
        "disabled_keys": disabled_keys
    }


def get_username_from_key(access_key_id):
    """ Retrieves username last associated with specified IAM access key ID.

    Args:
        access_key_id (string): IAM access key ID to lookup user with.

    Returns:
        (string)
        Username last associated with specified IAM access key ID.

    """
    try:
        response = iam.get_access_key_last_used(
            AccessKeyId=access_key_id
        )
    except Exception as e:
        print(e)
        print('Unable to retrieve username for access key "{}".'.format(access_key_id))
        raise(e)
    return response['UserName']


def disable_exposed_key_pair(username, access_key_id):
    """ Disables IAM access key pair identified by access key ID for specified user.

    Args:
        username (string): Username of IAM user to disable key pair for.
        access_key_id (string): IAM access key ID to identify key pair to disable.

    Returns:
        (None)

    """
    try:
        iam.update_access_key(
            UserName=username,
            AccessKeyId=access_key_id,
            Status='Inactive'
        ) 
    except Exception as e:
        print(e)
        print('Unable to disable access key "{}" for user "{}".'.format(access_key_id, username))
        raise(e)