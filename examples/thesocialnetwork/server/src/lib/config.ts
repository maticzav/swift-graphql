import * as env from 'dotenv'

if (process.env.NODE_ENV !== 'production') {
  const parsed = env.config({ debug: true, override: true })

  console.log(`Using .env environment variables:`)
  for (const key in parsed.parsed ?? {}) {
    console.log(`- ${key}`)
  }
}

export const config = {
  awsBase: 'https://s3.eu-central-1.amazonaws.com/',
  awsRegion: 'eu-central-1',
  awsS3Bucket: process.env.AWS_S3_BUCKET!,
  awsAccessKeyId: process.env.AWS_ACCESS_KEY_ID!,
  awsSecretAccessKey: process.env.AWS_SECRET_ACCESS_KEY!,
}
