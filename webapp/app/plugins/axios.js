export default function({ $axios, store }, inject) {
  const api = $axios.create()

  if (process.env.env === 'prod') {
    const apiBaseUrl = `${window.location.protocol}//${window.location.hostname}:8000/api/v1`
    api.setBaseURL(apiBaseUrl)
    $axios.setBaseURL(apiBaseUrl)
  }

  inject('api', api)
}
