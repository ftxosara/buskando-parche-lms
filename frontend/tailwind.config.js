module.exports = {
  content: ["./src/**/*.{js,ts,jsx,tsx,mdx}"],
  theme: {
    extend: {
      colors: {
        primary:   { DEFAULT:"#C0392B", light:"#E74C3C", dark:"#922B21" },
        secondary: { DEFAULT:"#F39C12", light:"#F5C518", dark:"#D68910" },
        surface:   { DEFAULT:"#FFFFFF", card:"#FFFFFF", border:"#E5E7EB", muted:"#F3F4F6" },
        text:      { primary:"#111827", secondary:"#374151", muted:"#9CA3AF" },
        success:"#16A34A", warning:"#D97706", error:"#DC2626", info:"#2563EB",
      },
      fontFamily: { sans:["Inter","system-ui","sans-serif"], display:["Poppins","sans-serif"] },
      backgroundImage: { "gradient-brand":"linear-gradient(135deg,#C0392B 0%,#922B21 100%)" },
      boxShadow: { brand:"0 4px 24px rgba(192,57,43,0.25)", card:"0 2px 12px rgba(0,0,0,0.08)" },
      animation: { "fade-in":"fadeIn 0.3s ease-out", "slide-up":"slideUp 0.4s ease-out" },
      keyframes: {
        fadeIn:  { from:{opacity:"0"}, to:{opacity:"1"} },
        slideUp: { from:{transform:"translateY(20px)",opacity:"0"}, to:{transform:"translateY(0)",opacity:"1"} },
      },
    },
  },
  plugins: [],
};