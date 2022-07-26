export const config = {
  awsBase: 'https://s3.eu-central-1.amazonaws.com/',
  awsS3Bucket: process.env.AWS_S3_BUCKET!,
  awsAccessKeyId: process.env.AWS_ACCESS_KEY_ID!,
  awsSecretAccessKey: process.env.AWS_SECRET_ACCESS_KEY!,
  awsRegion: process.env.AWS_REGION!,
}
