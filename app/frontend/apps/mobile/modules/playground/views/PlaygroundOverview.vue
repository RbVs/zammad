<!-- Copyright (C) 2012-2022 Zammad Foundation, https://zammad-foundation.org/ -->

<script setup lang="ts">
/* eslint-disable zammad/zammad-detect-translatable-string */

import Form from '@shared/components/Form/Form.vue'
import { defineFormSchema } from '@mobile/form/composable'
import { useDialog } from '@shared/composables/useDialog'
import CommonButtonGroup from '@mobile/components/CommonButtonGroup/CommonButtonGroup.vue'

const linkSchemaRaw = [
  {
    type: 'select',
    name: 'select',
    label: 'Select',
    props: {
      options: [
        { value: true, label: 'Yes' },
        { value: false, label: 'No' },
      ],
    },
  },
  {
    type: 'search',
    name: 'search',
    // label: 'Date_Input',
    props: {
      link: '/tickets',
    },
  },
  {
    type: 'tags',
    name: 'tags',
    label: 'Tags',
    props: {
      options: [
        { label: 'test', value: 'test' },
        { label: 'support', value: 'support' },
        { label: 'paid', value: 'paid' },
      ],
      canCreate: true,
    },
  },
  {
    type: 'treeselect',
    name: 'treeselect',
    label: 'TreeSelect',
    props: {
      multiple: true,
      options: [
        {
          value: 0,
          label: 'Item A',
          children: [
            {
              value: 1,
              label: 'Item 1',
              children: [
                {
                  value: 2,
                  label: 'Item I',
                },
                {
                  value: 3,
                  label: 'Item II',
                },
                {
                  value: 4,
                  label: 'Item III',
                },
              ],
            },
            {
              value: 5,
              label: 'Item 2',
              children: [
                {
                  value: 6,
                  label: 'Item IV',
                },
              ],
            },
            {
              value: 7,
              label: 'Item 3',
            },
          ],
        },
        {
          value: 8,
          label: 'Item B',
        },
        {
          value: 9,
          label: 'Ítem C',
        },
      ],
      link: '/tickets',
    },
  },
  {
    type: 'autocomplete',
    name: 'autocomplete',
    label: 'AutoComplete',
    props: {
      // options: [{ label: 'Label', value: 1 }],
      sorting: 'label',
      link: '/tickets',
      action: '/tickets',
      actionIcon: 'new-customer',
      gqlQuery: `
query autocompleteSearchUser($query: String!, $limit: Int) {
  autocompleteSearchUser(query: $query, limit: $limit) {
    value
    label
    labelPlaceholder
    heading
    headingPlaceholder
    disabled
    icon
  }
}
`,
    },
  },
]
const linkSchemas = defineFormSchema(linkSchemaRaw)

const schema = defineFormSchema([
  {
    isLayout: true,
    component: 'FormGroup',
    children: [
      {
        type: 'file',
        name: 'file',
        // label: 'File',
        props: {
          link: '/tickets',
        },
      },
    ],
  },
])

const dialog = useDialog({
  name: 'dialog',
  component: () => import('@mobile/components/CommonDialog/CommonDialog.vue'),
})
</script>

<template>
  <div class="p-4">
    <button @click="dialog.toggle({ name: 'dialog', label: 'Hello World' })">
      Dialog
    </button>

    <CommonButtonGroup
      class="py-4"
      :options="[
        { label: 'Merge tickets', icon: 'home' },
        { label: 'Subscribe', icon: 'home', selected: true },
        { label: 'Ticket info', icon: 'home' },
      ]"
    />

    <Form :schema="linkSchemas" />
    <Form :schema="schema" />

    <FormKit
      type="radio"
      :buttons="true"
      :options="[
        { label: 'Incoming Phone', value: 1, icon: 'received-calls' },
        { label: 'Outgoing Phone', value: 2, icon: 'outbound-calls' },
        { label: 'Send Email', value: 3, icon: 'email' },
      ]"
    />
  </div>
</template>
