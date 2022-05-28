# Helloworld

## How to invoke

```bash
aws lambda invoke \
  --function-name helloworld \
  --cli-binary-format raw-in-base64-out response.json

cat response.json
```
