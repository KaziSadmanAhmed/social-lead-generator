<template lang="pug">
  v-container
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
