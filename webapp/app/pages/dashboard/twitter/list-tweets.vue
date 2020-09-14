<template lang="pug">
  v-container.align-self-start
    TwitterConnect

    v-row

      v-card(max-width=400)

        v-card-text.headline Turns out semicolon-less style is easier and safer in TS because most gotcha edge cases are type invalid as well.

        v-card-actions
          v-list-item.grow
            v-list-item-avatar(color="grey darken-3")
              v-img.elevation-6(src="https://avataaars.io/?avatarStyle=Transparent&topType=ShortHairShortCurly&accessoriesType=Prescription02&hairColor=Black&facialHairType=Blank&clotheType=Hoodie&clotheColor=White&eyeType=Default&eyebrowType=DefaultNatural&mouthType=Default&skinColor=Light")

            v-list-item-content
              v-list-item-title Evan You

            v-row.pr-4(align="center" justify="end")
              v-icon.mr-1 mdi-heart
              span.subheading.mr-2 256
              v-icon.mr-1 mdi-message
              span.subheading.mr-2 20
              v-icon.mr-1(style="font-size: 32px") mdi-twitter-retweet
              span.subheading 45
</template>

<script>
import TwitterConnect from '@/components/core/auth/twitter/TwitterConnect'

export default {
  components: {
    TwitterConnect
  }
}
</script>
