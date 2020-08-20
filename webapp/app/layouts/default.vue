<template lang="pug">
  v-app
    NavBar
    v-content
      nuxt

</template>

<script>
import NavBar from '@/components/core/NavBar'

export default {
  components: {
    NavBar
  },
  data() {
    return {}
  }
}
</script>
