// Copyright (C) 2012-2022 Zammad Foundation, https://zammad-foundation.org/

import { ApolloLink } from '@apollo/client/core'
import { getMainDefinition } from '@apollo/client/utilities'
import { Kind } from 'graphql'

const isEmptyResponse = (response: unknown) => {
  if (!response) return true
  if (Array.isArray(response)) return response.length === 0
  if (typeof response === 'object') {
    // eslint-disable-next-line no-restricted-syntax
    for (const key in response) {
      // eslint-disable-next-line no-continue
      if (key === '__typename') continue
      if ((response as Record<string, string>)[key]) {
        return false
      }
    }
    return true
  }
  return false
}

const testFlagsLink = /* #__PURE__ */ new ApolloLink((operation, forward) => {
  return forward(operation).map((response) => {
    const definition = getMainDefinition(operation.query)
    if (definition.kind === Kind.FRAGMENT_DEFINITION) return response
    const operationType = definition.operation
    const operationName = definition.name?.value as string
    const flag = `__gql ${operationType} ${operationName}`
    if (operationType === 'subscription') {
      // only trigger subscription, if it was actually returned
      // this is also triggered with empty response, when we subscribe
      if (
        response.errors ||
        (response.data && !isEmptyResponse(response.data[operationName]))
      ) {
        window.testFlags?.set(flag)
      }
    } else {
      window.testFlags?.set(flag)
    }
    return response
  })
})

export default testFlagsLink
