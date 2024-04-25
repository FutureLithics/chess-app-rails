const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}'
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
      },
      colors: {
        baseBlack: "#0B0B0D",
        ancientBeige: "#C68740",
        paleBlue: "#688C8C",
        nightSea: "#162954",
        warriorRed: "#5F0B09",
        brightBlue: "#83E3C6",
        lightRed: "#DB120E",
        goldenText: "#D6E38A",
        coal: "#303030"
      }
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/aspect-ratio'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/container-queries'),
  ]
}
