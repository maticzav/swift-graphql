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
  name: Scalars['String'];
  token: Scalars['String'];
};

export type FormParams = {
  age: Scalars['Int'];
  master?: InputMaybe<Scalars['String']>;
  name: Scalars['String'];
};

export type Human = {
  name: Scalars['String'];
};

export type Master = Human & {
  __typename?: 'Master';
  age: Scalars['Int'];
  name: Scalars['String'];
};

export type Mutation = {
  __typename?: 'Mutation';
  /** A sample mutation that mimics a complex form and returns a */
  form: Human;
  /** A mutation that returns the token that may be used to authenticate the user. */
  login: AuthPayload;
};


export type MutationFormArgs = {
  params: FormParams;
};


export type MutationLoginArgs = {
  name: Scalars['String'];
};

export enum Option {
  One = 'ONE',
  Three = 'THREE',
  Two = 'TWO'
}

export type Padawan = Human & {
  __typename?: 'Padawan';
  age: Scalars['Int'];
  master: Master;
  name: Scalars['String'];
};

export type Query = {
  __typename?: 'Query';
  /** Query that returns the current date. */
  date?: Maybe<Scalars['DateTime']>;
  /** Simple query that says "Hello World!". */
  hello: Scalars['String'];
  /** A sample list of random strings. */
  list: Array<Scalars['String']>;
  /** A query that echos the selected enumerator back to the client. */
  oneOf: Option;
  /** A query that returns a value only when user is authenticated. */
  secret?: Maybe<Scalars['String']>;
};


export type QueryOneOfArgs = {
  option: Option;
};

export type Subscription = {
  __typename?: 'Subscription';
  /** A query that counts from a given value up/down to (excluding) target value. */
  count: Scalars['Int'];
  /** Countsdown from a given value to (including) 0 if you are authenticated. */
  secret: Scalars['Int'];
};


export type SubscriptionCountArgs = {
  from: Scalars['Int'];
  to: Scalars['Int'];
};


export type SubscriptionSecretArgs = {
  from: Scalars['Int'];
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
  FormParams: ResolverTypeWrapper<Partial<FormParams>>;
  Human: ResolversTypes['Master'] | ResolversTypes['Padawan'];
  Int: ResolverTypeWrapper<Partial<Scalars['Int']>>;
  Master: ResolverTypeWrapper<Partial<Master>>;
  Mutation: ResolverTypeWrapper<{}>;
  Option: ResolverTypeWrapper<Partial<Option>>;
  Padawan: ResolverTypeWrapper<Partial<Padawan>>;
  Query: ResolverTypeWrapper<{}>;
  String: ResolverTypeWrapper<Partial<Scalars['String']>>;
  Subscription: ResolverTypeWrapper<{}>;
};

/** Mapping between all available schema types and the resolvers parents */
export type ResolversParentTypes = {
  AuthPayload: Partial<ResolversParentTypes['AuthPayloadFailure'] | ResolversParentTypes['AuthPayloadSuccess']>;
  AuthPayloadFailure: Partial<AuthPayloadFailure>;
  AuthPayloadSuccess: Partial<AuthPayloadSuccess>;
  Boolean: Partial<Scalars['Boolean']>;
  DateTime: Partial<Scalars['DateTime']>;
  FormParams: Partial<FormParams>;
  Human: ResolversParentTypes['Master'] | ResolversParentTypes['Padawan'];
  Int: Partial<Scalars['Int']>;
  Master: Partial<Master>;
  Mutation: {};
  Padawan: Partial<Padawan>;
  Query: {};
  String: Partial<Scalars['String']>;
  Subscription: {};
};

export type AuthPayloadResolvers<ContextType = any, ParentType extends ResolversParentTypes['AuthPayload'] = ResolversParentTypes['AuthPayload']> = {
  __resolveType: TypeResolveFn<'AuthPayloadFailure' | 'AuthPayloadSuccess', ParentType, ContextType>;
};

export type AuthPayloadFailureResolvers<ContextType = any, ParentType extends ResolversParentTypes['AuthPayloadFailure'] = ResolversParentTypes['AuthPayloadFailure']> = {
  message?: Resolver<ResolversTypes['String'], ParentType, ContextType>;
  __isTypeOf?: IsTypeOfResolverFn<ParentType, ContextType>;
};

export type AuthPayloadSuccessResolvers<ContextType = any, ParentType extends ResolversParentTypes['AuthPayloadSuccess'] = ResolversParentTypes['AuthPayloadSuccess']> = {
  name?: Resolver<ResolversTypes['String'], ParentType, ContextType>;
  token?: Resolver<ResolversTypes['String'], ParentType, ContextType>;
  __isTypeOf?: IsTypeOfResolverFn<ParentType, ContextType>;
};

export interface DateTimeScalarConfig extends GraphQLScalarTypeConfig<ResolversTypes['DateTime'], any> {
  name: 'DateTime';
}

export type HumanResolvers<ContextType = any, ParentType extends ResolversParentTypes['Human'] = ResolversParentTypes['Human']> = {
  __resolveType: TypeResolveFn<'Master' | 'Padawan', ParentType, ContextType>;
  name?: Resolver<ResolversTypes['String'], ParentType, ContextType>;
};

export type MasterResolvers<ContextType = any, ParentType extends ResolversParentTypes['Master'] = ResolversParentTypes['Master']> = {
  age?: Resolver<ResolversTypes['Int'], ParentType, ContextType>;
  name?: Resolver<ResolversTypes['String'], ParentType, ContextType>;
  __isTypeOf?: IsTypeOfResolverFn<ParentType, ContextType>;
};

export type MutationResolvers<ContextType = any, ParentType extends ResolversParentTypes['Mutation'] = ResolversParentTypes['Mutation']> = {
  form?: Resolver<ResolversTypes['Human'], ParentType, ContextType, RequireFields<MutationFormArgs, 'params'>>;
  login?: Resolver<ResolversTypes['AuthPayload'], ParentType, ContextType, RequireFields<MutationLoginArgs, 'name'>>;
};

export type PadawanResolvers<ContextType = any, ParentType extends ResolversParentTypes['Padawan'] = ResolversParentTypes['Padawan']> = {
  age?: Resolver<ResolversTypes['Int'], ParentType, ContextType>;
  master?: Resolver<ResolversTypes['Master'], ParentType, ContextType>;
  name?: Resolver<ResolversTypes['String'], ParentType, ContextType>;
  __isTypeOf?: IsTypeOfResolverFn<ParentType, ContextType>;
};

export type QueryResolvers<ContextType = any, ParentType extends ResolversParentTypes['Query'] = ResolversParentTypes['Query']> = {
  date?: Resolver<Maybe<ResolversTypes['DateTime']>, ParentType, ContextType>;
  hello?: Resolver<ResolversTypes['String'], ParentType, ContextType>;
  list?: Resolver<Array<ResolversTypes['String']>, ParentType, ContextType>;
  oneOf?: Resolver<ResolversTypes['Option'], ParentType, ContextType, RequireFields<QueryOneOfArgs, 'option'>>;
  secret?: Resolver<Maybe<ResolversTypes['String']>, ParentType, ContextType>;
};

export type SubscriptionResolvers<ContextType = any, ParentType extends ResolversParentTypes['Subscription'] = ResolversParentTypes['Subscription']> = {
  count?: SubscriptionResolver<ResolversTypes['Int'], "count", ParentType, ContextType, RequireFields<SubscriptionCountArgs, 'from' | 'to'>>;
  secret?: SubscriptionResolver<ResolversTypes['Int'], "secret", ParentType, ContextType, RequireFields<SubscriptionSecretArgs, 'from'>>;
};

export type Resolvers<ContextType = any> = {
  AuthPayload?: AuthPayloadResolvers<ContextType>;
  AuthPayloadFailure?: AuthPayloadFailureResolvers<ContextType>;
  AuthPayloadSuccess?: AuthPayloadSuccessResolvers<ContextType>;
  DateTime?: GraphQLScalarType;
  Human?: HumanResolvers<ContextType>;
  Master?: MasterResolvers<ContextType>;
  Mutation?: MutationResolvers<ContextType>;
  Padawan?: PadawanResolvers<ContextType>;
  Query?: QueryResolvers<ContextType>;
  Subscription?: SubscriptionResolvers<ContextType>;
};

