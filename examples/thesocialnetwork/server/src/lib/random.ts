export namespace RandomUtils {
  /**
   * Generates a random string that may be used as a secret key
   * in the database.
   */
  export const generateSecretKey = (): string => {
    return generateRandomAlphaNumericString(32)
  }

  /**
   * Creates a random string of given length and picks charaters for
   * the string from the optional characters parameter.
   */
  export const generateRandomAlphaNumericString = (
    length: number,
    characters = 'abcdefghijklmnopqrstuvwxyz0123456789',
  ): string => {
    let result = ''
    const charactersLength = characters.length
    for (let i = 0; i < length; i++) {
      result += characters.charAt(Math.floor(Math.random() * charactersLength))
    }
    return result
  }
}
