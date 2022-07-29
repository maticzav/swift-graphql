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
};

export type Message = {
  __typename?: 'Message';
  createdAt: Scalars['DateTime'];
  id: Scalars['ID'];
  message: Scalars['String'];
  sender: User;
};

export type Mutation = {
  __typename?: 'Mutation';
  /** Returns an URL that may be used to upload the user image. */
  getProfilePictureSignedURL?: Maybe<SignedUrl>;
  /** A mutation that returns the token that may be used to authenticate the user. */
  login: AuthPayload;
  /** A mutation that lets you send a message to the feed. */
  message?: Maybe<Message>;
  /** Updates the profile picture of currently authenticated user. */
  setProfilePicture?: Maybe<User>;
};


export type MutationGetProfilePictureSignedUrlArgs = {
  contentType: Scalars['String'];
  extension: Scalars['String'];
};


export type MutationLoginArgs = {
  password: Scalars['String'];
  username: Scalars['String'];
};


export type MutationMessageArgs = {
  message: Scalars['String'];
};


export type MutationSetProfilePictureArgs = {
  file: Scalars['ID'];
};

export type Query = {
  __typename?: 'Query';
  /** A sample list of random strings. */
  feed: Array<Message>;
  viewer?: Maybe<User>;
};

export type SignedUrl = {
  __typename?: 'SignedURL';
  file_id: Scalars['String'];
  file_url: Scalars['String'];
  upload_url: Scalars['String'];
};

export type Subscription = {
  __typename?: 'Subscription';
  /** Number of new messages since the last fetch. */
  messages?: Maybe<Scalars['Int']>;
  /** Simple subscription that tells current time every second. */
  time: Scalars['DateTime'];
};

export type User = {
  __typename?: 'User';
  id: Scalars['ID'];
  isViewer: Scalars['Boolean'];
  picture?: Maybe<Scalars['String']>;
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
  DateTime: ResolverTypeWrapper<Partial<Scalars['DateTime']>>;
  ID: ResolverTypeWrapper<Partial<Scalars['ID']>>;
  Int: ResolverTypeWrapper<Partial<Scalars['Int']>>;
  Message: ResolverTypeWrapper<Partial<Message>>;
  Mutation: ResolverTypeWrapper<{}>;
  Query: ResolverTypeWrapper<{}>;
  SignedURL: ResolverTypeWrapper<Partial<SignedUrl>>;
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
  DateTime: Partial<Scalars['DateTime']>;
  ID: Partial<Scalars['ID']>;
  Int: Partial<Scalars['Int']>;
  Message: Partial<Message>;
  Mutation: {};
  Query: {};
  SignedURL: Partial<SignedUrl>;
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
  __isTypeOf?: IsTypeOfResolverFn<ParentType, ContextType>;
};

export interface DateTimeScalarConfig extends GraphQLScalarTypeConfig<ResolversTypes['DateTime'], any> {
  name: 'DateTime';
}

export type MessageResolvers<ContextType = any, ParentType extends ResolversParentTypes['Message'] = ResolversParentTypes['Message']> = {
  createdAt?: Resolver<ResolversTypes['DateTime'], ParentType, ContextType>;
  id?: Resolver<ResolversTypes['ID'], ParentType, ContextType>;
  message?: Resolver<ResolversTypes['String'], ParentType, ContextType>;
  sender?: Resolver<ResolversTypes['User'], ParentType, ContextType>;
  __isTypeOf?: IsTypeOfResolverFn<ParentType, ContextType>;
};

export type MutationResolvers<ContextType = any, ParentType extends ResolversParentTypes['Mutation'] = ResolversParentTypes['Mutation']> = {
  getProfilePictureSignedURL?: Resolver<Maybe<ResolversTypes['SignedURL']>, ParentType, ContextType, RequireFields<MutationGetProfilePictureSignedUrlArgs, 'contentType' | 'extension'>>;
  login?: Resolver<ResolversTypes['AuthPayload'], ParentType, ContextType, RequireFields<MutationLoginArgs, 'password' | 'username'>>;
  message?: Resolver<Maybe<ResolversTypes['Message']>, ParentType, ContextType, RequireFields<MutationMessageArgs, 'message'>>;
  setProfilePicture?: Resolver<Maybe<ResolversTypes['User']>, ParentType, ContextType, RequireFields<MutationSetProfilePictureArgs, 'file'>>;
};

export type QueryResolvers<ContextType = any, ParentType extends ResolversParentTypes['Query'] = ResolversParentTypes['Query']> = {
  feed?: Resolver<Array<ResolversTypes['Message']>, ParentType, ContextType>;
  viewer?: Resolver<Maybe<ResolversTypes['User']>, ParentType, ContextType>;
};

export type SignedUrlResolvers<ContextType = any, ParentType extends ResolversParentTypes['SignedURL'] = ResolversParentTypes['SignedURL']> = {
  file_id?: Resolver<ResolversTypes['String'], ParentType, ContextType>;
  file_url?: Resolver<ResolversTypes['String'], ParentType, ContextType>;
  upload_url?: Resolver<ResolversTypes['String'], ParentType, ContextType>;
  __isTypeOf?: IsTypeOfResolverFn<ParentType, ContextType>;
};

export type SubscriptionResolvers<ContextType = any, ParentType extends ResolversParentTypes['Subscription'] = ResolversParentTypes['Subscription']> = {
  messages?: SubscriptionResolver<Maybe<ResolversTypes['Int']>, "messages", ParentType, ContextType>;
  time?: SubscriptionResolver<ResolversTypes['DateTime'], "time", ParentType, ContextType>;
};

export type UserResolvers<ContextType = any, ParentType extends ResolversParentTypes['User'] = ResolversParentTypes['User']> = {
  id?: Resolver<ResolversTypes['ID'], ParentType, ContextType>;
  isViewer?: Resolver<ResolversTypes['Boolean'], ParentType, ContextType>;
  picture?: Resolver<Maybe<ResolversTypes['String']>, ParentType, ContextType>;
  username?: Resolver<ResolversTypes['String'], ParentType, ContextType>;
  __isTypeOf?: IsTypeOfResolverFn<ParentType, ContextType>;
};

export type Resolvers<ContextType = any> = {
  AuthPayload?: AuthPayloadResolvers<ContextType>;
  AuthPayloadFailure?: AuthPayloadFailureResolvers<ContextType>;
  AuthPayloadSuccess?: AuthPayloadSuccessResolvers<ContextType>;
  DateTime?: GraphQLScalarType;
  Message?: MessageResolvers<ContextType>;
  Mutation?: MutationResolvers<ContextType>;
  Query?: QueryResolvers<ContextType>;
  SignedURL?: SignedUrlResolvers<ContextType>;
  Subscription?: SubscriptionResolvers<ContextType>;
  User?: UserResolvers<ContextType>;
};

