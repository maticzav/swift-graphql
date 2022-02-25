import { GraphQLResolveInfo, GraphQLScalarType, GraphQLScalarTypeConfig } from 'graphql';
export type Maybe<T> = T | null;
export type InputMaybe<T> = Maybe<T>;
export type Exact<T extends { [key: string]: unknown }> = { [K in keyof T]: T[K] };
export type MakeOptional<T, K extends keyof T> = Omit<T, K> & { [SubKey in K]?: Maybe<T[SubKey]> };
export type MakeMaybe<T, K extends keyof T> = Omit<T, K> & { [SubKey in K]: Maybe<T[SubKey]> };
export type RequireFields<T, K extends keyof T> = Omit<T, K> & { [P in K]-?: NonNullable<T[P]> };
/** All built-in and custom scalars, mapped to their actual values */
export type Scalars = {
  ID: string;
  String: string;
  Boolean: boolean;
  Int: number;
  Float: number;
  DateTime: Date;
};

export type AuthPayload = AuthPayloadFailure | AuthPayloadSuccess;

export type AuthPayloadFailure = {
  __typename?: 'AuthPayloadFailure';
  message: Scalars['String'];
};

export type AuthPayloadSuccess = {
  __typename?: 'AuthPayloadSuccess';
  token: Scalars['String'];
  user: User;
};

export type Character = Node & {
  __typename?: 'Character';
  description: Scalars['String'];
  id: Scalars['ID'];
  /** URL of the character image. */
  image: Scalars['String'];
  name: Scalars['String'];
  /**
   * Tells whether currently authenticated user has starred this character.
   *
   * NOTE: If there's no authenticated user, this field will always return false.
   */
  starred: Scalars['Boolean'];
};

export type Comic = Node & {
  __typename?: 'Comic';
  description: Scalars['String'];
  id: Scalars['ID'];
  isbn: Scalars['String'];
  pageCount?: Maybe<Scalars['Int']>;
  /** Tells whether currently authenticated user has starred this comic. */
  starred: Scalars['Boolean'];
  /** URL of the thumbnail image. */
  thumbnail: Scalars['String'];
  title: Scalars['String'];
};

export type File = Node & {
  __typename?: 'File';
  id: Scalars['ID'];
  /** URL that may be used to access the file. */
  publicUrl: Scalars['String'];
  /** Signed URL that should be used to upload the file. */
  uploadUrl: Scalars['String'];
};

export enum Item {
  Character = 'CHARACTER',
  Comic = 'COMIC'
}

export type Message = Node & {
  __typename?: 'Message';
  author: User;
  date: Scalars['DateTime'];
  id: Scalars['ID'];
  image: File;
  message: Scalars['String'];
};

export type Mutation = {
  __typename?: 'Mutation';
  /** Creates a random authentication session. */
  auth: AuthPayload;
  /**
   * Messages the forum.
   *
   * NOTE: Image should be the id of the uploaded file.
   */
  message: Message;
  /** Adds a star to a comic or a character. */
  star: SearchResult;
  /**
   * Creates a new upload URL for a file and returns an ID.
   *
   * NOTE: The file should be uploaded to the returned URL. If the user is not
   * authenticated, mutation will throw an error.
   */
  uploadFile: File;
};


export type MutationMessageArgs = {
  image?: InputMaybe<Scalars['ID']>;
  message: Scalars['String'];
};


export type MutationStarArgs = {
  id: Scalars['ID'];
  item: Item;
};


export type MutationUploadFileArgs = {
  contentType: Scalars['String'];
  extension?: InputMaybe<Scalars['String']>;
  folder: Scalars['String'];
};

/** An object with an ID. */
export type Node = {
  /** ID of the object. */
  id: Scalars['ID'];
};

export type Pagination = {
  offset?: InputMaybe<Scalars['Int']>;
  /**
   * Number of items in a list that should be returned.
   *
   * NOTE: Maximum is 20 items.
   */
  take?: InputMaybe<Scalars['Int']>;
};

export type Query = {
  __typename?: 'Query';
  /** Returns a list of characters from the Marvel universe. */
  characters: Array<Character>;
  /** Returns a list of comics from the Marvel universe. */
  comics: Array<Comic>;
  /** Simple field that always returns "Hello world!". */
  hello: Scalars['String'];
  /** Lets you see send messages from other people. */
  messages: Array<Message>;
  /** Fetches an object given its ID. */
  node?: Maybe<Node>;
  /**
   * Searches all characters and comics by name and returns those whose
   * name starts with the query string.
   */
  search: Array<SearchResult>;
  /** Returns currently authenticated user and errors if there's no authenticated user. */
  user: User;
};


export type QueryCharactersArgs = {
  pagination?: InputMaybe<Pagination>;
};


export type QueryComicsArgs = {
  pagination?: InputMaybe<Pagination>;
};


export type QueryMessagesArgs = {
  pagination?: InputMaybe<Pagination>;
};


export type QueryNodeArgs = {
  id: Scalars['ID'];
};


export type QuerySearchArgs = {
  pagination?: InputMaybe<Pagination>;
  query: Search;
};

export type Search = {
  pagination?: InputMaybe<Pagination>;
  /** String used to compare the name of the item to. */
  query: Scalars['String'];
};

export type SearchResult = Character | Comic;

export type Subscription = {
  __typename?: 'Subscription';
  /** Triggered whene a new comment is added to the shared list of comments. */
  message: Message;
  /** Returns the current time from the server and refreshes every second. */
  time: Scalars['DateTime'];
};

export type User = Node & {
  __typename?: 'User';
  id: Scalars['ID'];
  /** A nickname user has picked for themself. */
  username: Scalars['String'];
};



export type ResolverTypeWrapper<T> = Promise<T> | T;


export type ResolverWithResolve<TResult, TParent, TContext, TArgs> = {
  resolve: ResolverFn<TResult, TParent, TContext, TArgs>;
};
export type Resolver<TResult, TParent = {}, TContext = {}, TArgs = {}> = ResolverFn<TResult, TParent, TContext, TArgs> | ResolverWithResolve<TResult, TParent, TContext, TArgs>;

export type ResolverFn<TResult, TParent, TContext, TArgs> = (
  parent: TParent,
  args: TArgs,
  context: TContext,
  info: GraphQLResolveInfo
) => Promise<TResult> | TResult;

export type SubscriptionSubscribeFn<TResult, TParent, TContext, TArgs> = (
  parent: TParent,
  args: TArgs,
  context: TContext,
  info: GraphQLResolveInfo
) => AsyncIterable<TResult> | Promise<AsyncIterable<TResult>>;

export type SubscriptionResolveFn<TResult, TParent, TContext, TArgs> = (
  parent: TParent,
  args: TArgs,
  context: TContext,
  info: GraphQLResolveInfo
) => TResult | Promise<TResult>;

export interface SubscriptionSubscriberObject<TResult, TKey extends string, TParent, TContext, TArgs> {
  subscribe: SubscriptionSubscribeFn<{ [key in TKey]: TResult }, TParent, TContext, TArgs>;
  resolve?: SubscriptionResolveFn<TResult, { [key in TKey]: TResult }, TContext, TArgs>;
}

export interface SubscriptionResolverObject<TResult, TParent, TContext, TArgs> {
  subscribe: SubscriptionSubscribeFn<any, TParent, TContext, TArgs>;
  resolve: SubscriptionResolveFn<TResult, any, TContext, TArgs>;
}

export type SubscriptionObject<TResult, TKey extends string, TParent, TContext, TArgs> =
  | SubscriptionSubscriberObject<TResult, TKey, TParent, TContext, TArgs>
  | SubscriptionResolverObject<TResult, TParent, TContext, TArgs>;

export type SubscriptionResolver<TResult, TKey extends string, TParent = {}, TContext = {}, TArgs = {}> =
  | ((...args: any[]) => SubscriptionObject<TResult, TKey, TParent, TContext, TArgs>)
  | SubscriptionObject<TResult, TKey, TParent, TContext, TArgs>;

export type TypeResolveFn<TTypes, TParent = {}, TContext = {}> = (
  parent: TParent,
  context: TContext,
  info: GraphQLResolveInfo
) => Maybe<TTypes> | Promise<Maybe<TTypes>>;

export type IsTypeOfResolverFn<T = {}, TContext = {}> = (obj: T, context: TContext, info: GraphQLResolveInfo) => boolean | Promise<boolean>;

export type NextResolverFn<T> = () => Promise<T>;

export type DirectiveResolverFn<TResult = {}, TParent = {}, TContext = {}, TArgs = {}> = (
  next: NextResolverFn<TResult>,
  parent: TParent,
  args: TArgs,
  context: TContext,
  info: GraphQLResolveInfo
) => TResult | Promise<TResult>;

/** Mapping between all available schema types and the resolvers types */
export type ResolversTypes = {
  AuthPayload: Partial<ResolversTypes['AuthPayloadFailure'] | ResolversTypes['AuthPayloadSuccess']>;
  AuthPayloadFailure: ResolverTypeWrapper<Partial<AuthPayloadFailure>>;
  AuthPayloadSuccess: ResolverTypeWrapper<Partial<AuthPayloadSuccess>>;
  Boolean: ResolverTypeWrapper<Partial<Scalars['Boolean']>>;
  Character: ResolverTypeWrapper<Partial<Character>>;
  Comic: ResolverTypeWrapper<Partial<Comic>>;
  DateTime: ResolverTypeWrapper<Partial<Scalars['DateTime']>>;
  File: ResolverTypeWrapper<Partial<File>>;
  ID: ResolverTypeWrapper<Partial<Scalars['ID']>>;
  Int: ResolverTypeWrapper<Partial<Scalars['Int']>>;
  Item: ResolverTypeWrapper<Partial<Item>>;
  Message: ResolverTypeWrapper<Partial<Message>>;
  Mutation: ResolverTypeWrapper<{}>;
  Node: ResolversTypes['Character'] | ResolversTypes['Comic'] | ResolversTypes['File'] | ResolversTypes['Message'] | ResolversTypes['User'];
  Pagination: ResolverTypeWrapper<Partial<Pagination>>;
  Query: ResolverTypeWrapper<{}>;
  Search: ResolverTypeWrapper<Partial<Search>>;
  SearchResult: Partial<ResolversTypes['Character'] | ResolversTypes['Comic']>;
  String: ResolverTypeWrapper<Partial<Scalars['String']>>;
  Subscription: ResolverTypeWrapper<{}>;
  User: ResolverTypeWrapper<Partial<User>>;
};

/** Mapping between all available schema types and the resolvers parents */
export type ResolversParentTypes = {
  AuthPayload: Partial<ResolversParentTypes['AuthPayloadFailure'] | ResolversParentTypes['AuthPayloadSuccess']>;
  AuthPayloadFailure: Partial<AuthPayloadFailure>;
  AuthPayloadSuccess: Partial<AuthPayloadSuccess>;
  Boolean: Partial<Scalars['Boolean']>;
  Character: Partial<Character>;
  Comic: Partial<Comic>;
  DateTime: Partial<Scalars['DateTime']>;
  File: Partial<File>;
  ID: Partial<Scalars['ID']>;
  Int: Partial<Scalars['Int']>;
  Message: Partial<Message>;
  Mutation: {};
  Node: ResolversParentTypes['Character'] | ResolversParentTypes['Comic'] | ResolversParentTypes['File'] | ResolversParentTypes['Message'] | ResolversParentTypes['User'];
  Pagination: Partial<Pagination>;
  Query: {};
  Search: Partial<Search>;
  SearchResult: Partial<ResolversParentTypes['Character'] | ResolversParentTypes['Comic']>;
  String: Partial<Scalars['String']>;
  Subscription: {};
  User: Partial<User>;
};

export type AuthPayloadResolvers<ContextType = any, ParentType extends ResolversParentTypes['AuthPayload'] = ResolversParentTypes['AuthPayload']> = {
  __resolveType: TypeResolveFn<'AuthPayloadFailure' | 'AuthPayloadSuccess', ParentType, ContextType>;
};

export type AuthPayloadFailureResolvers<ContextType = any, ParentType extends ResolversParentTypes['AuthPayloadFailure'] = ResolversParentTypes['AuthPayloadFailure']> = {
  message?: Resolver<ResolversTypes['String'], ParentType, ContextType>;
  __isTypeOf?: IsTypeOfResolverFn<ParentType, ContextType>;
};

export type AuthPayloadSuccessResolvers<ContextType = any, ParentType extends ResolversParentTypes['AuthPayloadSuccess'] = ResolversParentTypes['AuthPayloadSuccess']> = {
  token?: Resolver<ResolversTypes['String'], ParentType, ContextType>;
  user?: Resolver<ResolversTypes['User'], ParentType, ContextType>;
  __isTypeOf?: IsTypeOfResolverFn<ParentType, ContextType>;
};

export type CharacterResolvers<ContextType = any, ParentType extends ResolversParentTypes['Character'] = ResolversParentTypes['Character']> = {
  description?: Resolver<ResolversTypes['String'], ParentType, ContextType>;
  id?: Resolver<ResolversTypes['ID'], ParentType, ContextType>;
  image?: Resolver<ResolversTypes['String'], ParentType, ContextType>;
  name?: Resolver<ResolversTypes['String'], ParentType, ContextType>;
  starred?: Resolver<ResolversTypes['Boolean'], ParentType, ContextType>;
  __isTypeOf?: IsTypeOfResolverFn<ParentType, ContextType>;
};

export type ComicResolvers<ContextType = any, ParentType extends ResolversParentTypes['Comic'] = ResolversParentTypes['Comic']> = {
  description?: Resolver<ResolversTypes['String'], ParentType, ContextType>;
  id?: Resolver<ResolversTypes['ID'], ParentType, ContextType>;
  isbn?: Resolver<ResolversTypes['String'], ParentType, ContextType>;
  pageCount?: Resolver<Maybe<ResolversTypes['Int']>, ParentType, ContextType>;
  starred?: Resolver<ResolversTypes['Boolean'], ParentType, ContextType>;
  thumbnail?: Resolver<ResolversTypes['String'], ParentType, ContextType>;
  title?: Resolver<ResolversTypes['String'], ParentType, ContextType>;
  __isTypeOf?: IsTypeOfResolverFn<ParentType, ContextType>;
};

export interface DateTimeScalarConfig extends GraphQLScalarTypeConfig<ResolversTypes['DateTime'], any> {
  name: 'DateTime';
}

export type FileResolvers<ContextType = any, ParentType extends ResolversParentTypes['File'] = ResolversParentTypes['File']> = {
  id?: Resolver<ResolversTypes['ID'], ParentType, ContextType>;
  publicUrl?: Resolver<ResolversTypes['String'], ParentType, ContextType>;
  uploadUrl?: Resolver<ResolversTypes['String'], ParentType, ContextType>;
  __isTypeOf?: IsTypeOfResolverFn<ParentType, ContextType>;
};

export type MessageResolvers<ContextType = any, ParentType extends ResolversParentTypes['Message'] = ResolversParentTypes['Message']> = {
  author?: Resolver<ResolversTypes['User'], ParentType, ContextType>;
  date?: Resolver<ResolversTypes['DateTime'], ParentType, ContextType>;
  id?: Resolver<ResolversTypes['ID'], ParentType, ContextType>;
  image?: Resolver<ResolversTypes['File'], ParentType, ContextType>;
  message?: Resolver<ResolversTypes['String'], ParentType, ContextType>;
  __isTypeOf?: IsTypeOfResolverFn<ParentType, ContextType>;
};

export type MutationResolvers<ContextType = any, ParentType extends ResolversParentTypes['Mutation'] = ResolversParentTypes['Mutation']> = {
  auth?: Resolver<ResolversTypes['AuthPayload'], ParentType, ContextType>;
  message?: Resolver<ResolversTypes['Message'], ParentType, ContextType, RequireFields<MutationMessageArgs, 'message'>>;
  star?: Resolver<ResolversTypes['SearchResult'], ParentType, ContextType, RequireFields<MutationStarArgs, 'id' | 'item'>>;
  uploadFile?: Resolver<ResolversTypes['File'], ParentType, ContextType, RequireFields<MutationUploadFileArgs, 'contentType' | 'folder'>>;
};

export type NodeResolvers<ContextType = any, ParentType extends ResolversParentTypes['Node'] = ResolversParentTypes['Node']> = {
  __resolveType: TypeResolveFn<'Character' | 'Comic' | 'File' | 'Message' | 'User', ParentType, ContextType>;
  id?: Resolver<ResolversTypes['ID'], ParentType, ContextType>;
};

export type QueryResolvers<ContextType = any, ParentType extends ResolversParentTypes['Query'] = ResolversParentTypes['Query']> = {
  characters?: Resolver<Array<ResolversTypes['Character']>, ParentType, ContextType, Partial<QueryCharactersArgs>>;
  comics?: Resolver<Array<ResolversTypes['Comic']>, ParentType, ContextType, Partial<QueryComicsArgs>>;
  hello?: Resolver<ResolversTypes['String'], ParentType, ContextType>;
  messages?: Resolver<Array<ResolversTypes['Message']>, ParentType, ContextType, Partial<QueryMessagesArgs>>;
  node?: Resolver<Maybe<ResolversTypes['Node']>, ParentType, ContextType, RequireFields<QueryNodeArgs, 'id'>>;
  search?: Resolver<Array<ResolversTypes['SearchResult']>, ParentType, ContextType, RequireFields<QuerySearchArgs, 'query'>>;
  user?: Resolver<ResolversTypes['User'], ParentType, ContextType>;
};

export type SearchResultResolvers<ContextType = any, ParentType extends ResolversParentTypes['SearchResult'] = ResolversParentTypes['SearchResult']> = {
  __resolveType: TypeResolveFn<'Character' | 'Comic', ParentType, ContextType>;
};

export type SubscriptionResolvers<ContextType = any, ParentType extends ResolversParentTypes['Subscription'] = ResolversParentTypes['Subscription']> = {
  message?: SubscriptionResolver<ResolversTypes['Message'], "message", ParentType, ContextType>;
  time?: SubscriptionResolver<ResolversTypes['DateTime'], "time", ParentType, ContextType>;
};

export type UserResolvers<ContextType = any, ParentType extends ResolversParentTypes['User'] = ResolversParentTypes['User']> = {
  id?: Resolver<ResolversTypes['ID'], ParentType, ContextType>;
  username?: Resolver<ResolversTypes['String'], ParentType, ContextType>;
  __isTypeOf?: IsTypeOfResolverFn<ParentType, ContextType>;
};

export type Resolvers<ContextType = any> = {
  AuthPayload?: AuthPayloadResolvers<ContextType>;
  AuthPayloadFailure?: AuthPayloadFailureResolvers<ContextType>;
  AuthPayloadSuccess?: AuthPayloadSuccessResolvers<ContextType>;
  Character?: CharacterResolvers<ContextType>;
  Comic?: ComicResolvers<ContextType>;
  DateTime?: GraphQLScalarType;
  File?: FileResolvers<ContextType>;
  Message?: MessageResolvers<ContextType>;
  Mutation?: MutationResolvers<ContextType>;
  Node?: NodeResolvers<ContextType>;
  Query?: QueryResolvers<ContextType>;
  SearchResult?: SearchResultResolvers<ContextType>;
  Subscription?: SubscriptionResolvers<ContextType>;
  User?: UserResolvers<ContextType>;
};

