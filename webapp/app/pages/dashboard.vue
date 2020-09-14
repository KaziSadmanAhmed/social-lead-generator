<template lang="pug">
  v-container.fill-height
    SideBar
    nuxt-child
</template>

<script>
import SideBar from '@/components/core/SideBar'

export default {
  components: {
    SideBar
  },
  data: () => ({}),
  middleware: 'auth'
}
</script>
