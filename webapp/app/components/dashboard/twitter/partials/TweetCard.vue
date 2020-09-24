<template lang="pug">
  v-card.d-flex.flex-column.fill-height
    v-card-text.headline.flex-grow-1 {{ tweet.text }}

    v-card-actions.pb-0
      v-list-item.grow(two-line)
        v-list-item-avatar(color="grey darken-3")
          v-img.elevation-6(:src="tweet.user.profile_image_url")

        v-list-item-content
          v-list-item-title {{ tweet.user.name }}
          v-list-item-subtitle.grey--text @{{ tweet.user.screen_name }}

    v-card-actions.pt-0
      v-list-item

        v-list-item-content(style="min-width: 150px;")
          v-list-item-subtitle.grey--text {{ tweet.created_at }}

        v-row.pr-4(align="center" justify="end")
          v-icon.mr-1 mdi-heart
          span.subheading.mr-2 {{ tweet.favorite_count }}
          v-icon.mr-1(style="font-size: 32px") mdi-twitter-retweet
          span.subheading {{ tweet.retweet_count }}
</template>

<script>
export default {
  props: {
    tweet: {
      type: Object,
      default: () => ({}),
      required: true
    }
  }
}
</script>
