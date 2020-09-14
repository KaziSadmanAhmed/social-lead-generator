<template lang="pug">
  v-app-bar(color="primary" app)
    v-app-bar-nav-icon(v-if="$route.path.startsWith('/dashboard') && $auth.loggedIn" dark @click="$emit('toggleSidebar')")
    v-toolbar-title.white--text Social Lead Generator
</template>
