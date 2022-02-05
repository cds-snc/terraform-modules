import connector

def lambda_handler(event, context):
    try:
        # Passes the event to the Sentinel connector layer
        connector.handle_log(event):
        return True
    except Exception as e:
        print(e)

