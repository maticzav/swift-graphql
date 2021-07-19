import { makeSchema } from 'nexus'
import * as path from 'path'

import { data } from './data'
import * as allTypes from './graphql'
import { ContextType } from './types/backingTypes'

/* Schema */

const schema = makeSchema({
  types: allTypes,
  nonNullDefaults: {
    input: true,
    output: true,
  },
  outputs: {
    typegen: path.join(__dirname, 'nexus.types.ts'),
    schema: path.join(__dirname, './schema.graphql'),
  },
  sourceTypes: {
    modules: [
      {
        module: path.join(__dirname.replace(/\/dist$/, '/src'), './types/backingTypes.ts'),
        alias: 'swapi',
      },
    ],
  },
  contextType: {
    module: path.join(__dirname.replace(/\/dist$/, '/src'), './types/backingTypes.ts'),
    export: 'ContextType',
  },
  prettierConfig: require.resolve('../../prettier.config.js'),
})

/* Server */

const express = require("express");
//import express from 'express';
const ws = require("ws");
// import ws from 'ws'; // yarn add ws
import { useServer } from 'graphql-ws/lib/use/ws';
import { execute, subscribe, GraphQLError } from 'graphql';
import { createServer, IncomingMessage, Server } from 'http';
import { graphqlHTTP } from 'express-graphql';

const port = process.env.PORT || 4000;

const http = express();
const httpServer = createServer(http);

http.use('/graphql', async (req: any, res: any) => {
  const context: any = { req: req, data: data };

	graphqlHTTP({
		schema: schema,
		context: context
	})(req, res);
});

const wsServer = new ws.Server({
  server: httpServer,
  path: '/subscriptions'
});

useServer(
  {
    schema,
    execute,
    subscribe,
    onConnect: (ctx) => {
      console.log('Connect', ctx);
      ctx["data"] = data
    },
    onSubscribe: (ctx, msg) => {
      console.log('Subscribe', { ctx, msg });
    },
    onNext: (ctx, msg, args, result) => {
      console.debug('Next', { ctx, msg, args, result });
    },
    onError: (ctx, msg, errors) => {
      console.error('Error', { ctx, msg, errors });
    },
    onComplete: (ctx, msg) => {
      console.log('Complete', { ctx, msg });
    }
  },
  wsServer
);

httpServer.listen(port, () => {
	console.log(`HTTP server listening on port ${port}`);
});

console.log(`🚀 Server ready at http://localhost:${port}/graphql`);
