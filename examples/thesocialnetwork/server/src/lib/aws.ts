import { PutObjectCommand, S3Client } from '@aws-sdk/client-s3'
import { getSignedUrl } from '@aws-sdk/s3-request-presigner'
import { v4 as uuid } from 'uuid'

import { config } from './config'
import { generateAlphaNumericString } from './random'

/**
 * Returns a file key from a file url.
 */
export const getFileKey = ({ fileURL }: { fileURL: string }): string => {
  return fileURL.replace(config.awsBase, '').replace(`${config.awsS3Bucket}/`, '')
}

/**
 * Converts file key to a public URL.
 */
export const getFileURL = ({ fileKey }: { fileKey: string }): string => {
  return config.awsBase + config.awsS3Bucket + fileKey
}

/**
 * Returns information that you need to upload a file to the walletta CDN.
 */
export const getFileUploadValues = async ({
  extension,
  contentType,
  folder,
}: {
  extension?: string | null
  contentType: string
  folder: string
}): Promise<{
  file_url: string
  file_key: string
  upload_url: string
}> => {
  const client = new S3Client({
    credentials: {
      accessKeyId: config.awsAccessKeyId,
      secretAccessKey: config.awsSecretAccessKey,
    },
    region: config.awsRegion,
  })

  // Include extension for gifs so we can identify them from their url,
  // without knowing their content type.
  if (extension == null && contentType === 'image/gif') {
    extension = 'gif'
  }

  const Key = generateS3Key({ folder, extension })

  const command = new PutObjectCommand({
    Bucket: config.awsS3Bucket,
    Key,
    ContentType: contentType,
    ACL: 'public-read',
  })
  const upload_url = await getSignedUrl(client, command, { expiresIn: 3600 })

  const file_key = `/${Key}`
  const file_url = getFileURL({ fileKey: file_key })

  return {
    upload_url,
    file_url,
    file_key,
  }
}

export const generateS3Key = ({ folder, extension }: { folder: string; extension?: string | null }): string => {
  // S3 performance is tied to the file prefix, so by creating more prefixes, we improve S3 perf
  // https://docs.aws.amazon.com/AmazonS3/latest/dev/optimizing-performance.html
  const randomStr = generateAlphaNumericString(2)
  let Key = `${folder}/${randomStr}/${uuid()}`
  if (extension) {
    Key += '.' + extension
  }

  return Key
}
