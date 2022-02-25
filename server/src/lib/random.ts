/**
 * Generates a random string that may be used as a secret key
 * in the database.
 */
export const generateSecretKey = (): string => {
  return generateAlphaNumericString(10)
}

/**
 * Creates a random string of given length and picks
 * charaters for the string from the optional characters parameter.
 */
export const generateAlphaNumericString = (length: number, characters = 'abcdefghijklmnopqrstuvwxyz0123456789'): string => {
  let result = ''
  const charactersLength = characters.length
  for (let i = 0; i < length; i++) {
    result += characters.charAt(Math.floor(Math.random() * charactersLength))
  }
  return result
}

// Random English names.
const NAMES = [
  'Aaliyah',
  'Aaron',
  'Abagail',
  'Abbey',
  'Abbie',
  'Candace',
  'Cindy',
  'Cinderella',
  'Cindy',
  'Denise',
  'Denny',
  'Don',
  'Donna',
  'Dora',
  'George',
  'Gina',
  'Ginger',
  'Harvey',
  'Irene',
  'Jack',
  'Kathy',
  'Linda',
  'Mathew',
  'Molly',
  'Nancy',
  'Olivia',
  'Patty',
  'Paul',
  'Randy',
  'Rita',
  'Queen',
  'Sally',
  'Samantha',
  'Sandy',
  'Tina',
  'Tom',
  'Ursula',
  'Vicky',
  'Vincent',
  'Violet',
  'Wendy',
  'Willie',
  'Zachary',
  'Zoe',
]

/**
 * Returns a random human name.
 */
export function generateRandomName(): string {
  return NAMES[(Math.random() * NAMES.length) | 0]
}
