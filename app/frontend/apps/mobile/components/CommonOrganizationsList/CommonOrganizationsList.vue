<!-- Copyright (C) 2012-2022 Zammad Foundation, https://zammad-foundation.org/ -->

<script setup lang="ts">
import type { AvatarOrganization } from '@shared/components/CommonOrganizationAvatar'
import CommonOrganizationAvatar from '@shared/components/CommonOrganizationAvatar/CommonOrganizationAvatar.vue'
import CommonSectionMenu from '../CommonSectionMenu/CommonSectionMenu.vue'

interface Props {
  organizations: (AvatarOrganization & { id: string; internalId: number })[]
  label?: string
}

defineProps<Props>()
</script>

<template>
  <CommonSectionMenu v-if="organizations.length" :header-label="label">
    <CommonLink
      v-for="organization of organizations"
      :key="organization.id"
      :link="`/organizations/${organization.internalId}`"
      class="flex min-h-[66px] items-center"
    >
      <CommonOrganizationAvatar
        :entity="organization"
        class="ltr:mr-3 rtl:ml-3"
      />
      <span class="overflow-hidden text-ellipsis whitespace-nowrap">
        {{ organization.name }}
      </span>
    </CommonLink>
  </CommonSectionMenu>
</template>
