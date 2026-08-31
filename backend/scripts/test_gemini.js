const https = require('https');

const apiKey = process.env.GEMINI_API_KEY || Buffer.from("QVEuQWI4Uk42SS1KMDhuRzhWZWhtWXhkRWR0c0JkY1pUaEM4bU1Tc3dRMjktNVJZVXNid1E=", "base64").toString("utf-8");
const payload = JSON.stringify({
  contents: [
    {
      parts: [
        { text: "Solo Leveling System AI: Say hello to Hunter Anush and confirm Gemini Awakening." }
      ]
    }
  ]
});

const options = {
  hostname: 'generativelanguage.googleapis.com',
  port: 443,
  path: `/v1beta/models/gemini-3.6-flash:generateContent`,
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'x-goog-api-key': apiKey,
    'Content-Length': Buffer.byteLength(payload)
  }
};

const req = https.request(options, (res) => {
  let data = '';
  res.on('data', (chunk) => { data += chunk; });
  res.on('end', () => {
    console.log("Status:", res.statusCode);
    try {
      const parsed = JSON.parse(data);
      console.log("Response:", parsed.candidates[0].content.parts[0].text);
    } catch(e) {
      console.log("Raw Response:", data);
    }
  });
});

req.on('error', (e) => {
  console.error(e);
});

req.write(payload);
req.end();
