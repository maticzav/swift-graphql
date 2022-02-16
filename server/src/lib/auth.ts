// /**
//  * Returns an autohrization property.
//  */
// export function getAuthorization(ctx: Context) {
//   const Authorization = ctx.req.get('Authorization')
//   if (Authorization) {
//     const token = Authorization.replace('Bearer ', '')
//     return token
//   }

//   throw new AuthError()
// }

// export class AuthError extends Error {
//   constructor() {
//     super('Not authorized')
//   }
// }
