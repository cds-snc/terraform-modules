/* Lambda function to get the total cost of the AWS account and send a message to a Slack channel with the total cost. */

const AWS = require('aws-sdk');
const costexplorer = new AWS.CostExplorer({ region: 'us-east-1' });

const https = require('https')

exports.handler = async (event) => {
  const hook = event.hook;
  const account_name = process.env.ACCOUNT_NAME; 
  const today = new Date();

  // get the current account
  let account = await getCurrentAccount()

  // get the current account cost
  const accountCost = await getAccountCost()

  // get the total cost
  const totalCost = Object.values(accountCost).reduce((a, b) => a + b, 0)

  // construct the Slack message
  const header = {
          "type": "header",
          "text": {
            "type": "plain_text",
            "text": `Current AWS spend for ${(today.getMonth() + 1).pad(2)}-${today.getFullYear()}`,
            "emoji": true
          }
        }

  const footer = {
          "type": "section",
          "fields": [{ "type": "mrkdwn", "text": `*Total for ${account} *` }, { "type": "mrkdwn", "text": `$${totalCost.toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,')} USD` }]
        }
    

  blocks = []
  blocks.splice(0,0, header)
  blocks.push({ "type": "divider"})
  blocks.push(footer)

  const data = JSON.stringify(
    {
      "blocks": blocks
    }
  )
  
  console.log(data)
  const options = {
    hostname: 'sre-bot.cdssandbox.xyz',
    port: 443,
    path: `/hook/${hook}`,
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Content-Length': data.length
    }
  }
  const resp = await doRequest(options, data);
  console.log(resp)

  const response = {
    statusCode: 200,
    body: JSON.stringify({ success: true }),
  };
  return response;
};

// return the current account id
async function getCurrentAccount() {
  const sts = new AWS.STS();
  const data = await sts.getCallerIdentity({}).promise();
  return data.Account;
}

// return the current daily cost for the account so far
async function getAccountCost() {
  const today = new Date();
  const firstDayOfMonth = new Date(today.getFullYear(), today.getMonth(), 1).toISOString().split("T")[0];
  const lastDayOfMonth = new Date(today.getFullYear(), today.getMonth() + 1, 0).toISOString().split("T")[0];

  const params = {
    Granularity: "MONTHLY",
    TimePeriod: { Start: firstDayOfMonth, End: lastDayOfMonth },
    Metrics: ["UNBLENDED_COST"],
    GroupBy: [
      {
        Type: "DIMENSION",
        Key: "LINKED_ACCOUNT"
      }]
  };

  const result = await costexplorer.getCostAndUsage(params).promise();
  return result["ResultsByTime"][0]["Groups"].reduce((acc, curr) => {
    acc[curr["Keys"][0]] = parseFloat(curr["Metrics"]["UnblendedCost"]["Amount"]);
    return acc;
  }, {});
}

function doRequest(options, data) {
  return new Promise((resolve, reject) => {
    const req = https.request(options, (res) => {
      res.setEncoding('utf8');
      let responseBody = '';

      res.on('data', (chunk) => {
        responseBody += chunk;
      });

      res.on('end', () => {
        resolve(responseBody);
      });
    });

    req.on('error', (err) => {
      reject(err);
    });

    req.write(data)
    req.end();
  });
}

Number.prototype.pad = function (size) {
  var s = String(this);
  while (s.length < (size || 2)) { s = "0" + s; }
  return s;
}