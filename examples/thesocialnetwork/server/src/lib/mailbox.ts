export class Mailbox {
  /**
   * Number of messages that each user hasn't read yet identified by the user id.
   */
  private messages: { [user: string]: number }

  constructor() {
    this.messages = {}
  }

  /**
   * Creates a new mailbox for the given user.
   */
  public createUserMailbox(user: string) {
    this.messages[user] = 0
  }

  /**
   * Method that adds new messages to the mailbox of each active user
   * and returns the new state of the mailboxes.
   */
  public received(count: number): { userId: string; count: number }[] {
    for (const user in this.messages) {
      this.messages[user] += count
    }

    return Object.entries(this.messages).map(([user, count]) => ({ userId: user, count }))
  }

  /**
   * Drains the messages of the given user.
   */
  public drain(user: string): number {
    const messages = this.messages[user]
    this.messages[user] = 0
    return messages
  }
}
