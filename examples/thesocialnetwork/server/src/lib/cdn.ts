import { PutObjectCommand, S3Client } from '@aws-sdk/client-s3'
import { getSignedUrl } from '@aws-sdk/s3-request-presigner'
import { v4 as uuid } from 'uuid'

import { config } from './config'
import { RandomUtils } from './random'

const client = new S3Client({
  credentials: {
    accessKeyId: config.awsAccessKeyId,
    secretAccessKey: config.awsSecretAccessKey,
  },
  region: config.awsRegion,
})

export namespace CDNUtils {
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

    return { upload_url, file_url, file_key }
  }

  /**
   * Returns a unique identifier that may be used as a key of a file.
   */
  const generateS3Key = ({ folder, extension }: { folder: string; extension?: string | null }): string => {
    // S3 performance is tied to the file prefix. By creating more prefixes,
    // we improve S3 performance (https://docs.aws.amazon.com/AmazonS3/latest/dev/optimizing-performance.html).
    const subfolder = RandomUtils.generateRandomAlphaNumericString(2)
    const id = uuid()

    let key = `${folder}/${subfolder}/${id}`
    if (extension) {
      key += '.' + extension
    }
    return key
  }

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
}
