(function () {
  const dict = window.PDC_I18N;
  const layers = window.PDC_LAYERS;
  const stored = localStorage.getItem("pdc-lang");
  const browserPl = (navigator.language || "").toLowerCase().startsWith("pl");
  let lang = stored === "pl" || stored === "en" ? stored : (browserPl ? "pl" : "en");

  function apply(next) {
    lang = next;
    localStorage.setItem("pdc-lang", lang);
    document.documentElement.lang = lang === "pl" ? "pl" : "en";
    const table = dict[lang];
    document.querySelectorAll("[data-i18n]").forEach((el) => {
      const value = table[el.dataset.i18n];
      if (value == null) return;
      if (el.dataset.i18nHtml === "1") el.innerHTML = value;
      else el.textContent = value;
    });
    document.querySelectorAll(".lang button").forEach((btn) => {
      btn.setAttribute("aria-pressed", btn.dataset.lang === lang ? "true" : "false");
    });
    renderLayers();
  }

  function renderLayers() {
    const host = document.querySelector("[data-layers]");
    if (!host || !layers) return;
    const pack = layers[lang];
    const current = host.dataset.current || pack[0].id;
    host.dataset.current = current;
    host.innerHTML = pack.map((layer) => {
      const pressed = layer.id === current ? "true" : "false";
      return `<button class="layer" type="button" data-layer="${layer.id}" aria-pressed="${pressed}"><small>${layer.n} · ${layer.hides}</small><strong>${layer.name}</strong></button>`;
    }).join("");
    const layer = pack.find((item) => item.id === current) || pack[0];
    const title = document.querySelector("[data-layer-title]");
    const body = document.querySelector("[data-layer-body]");
    const meta = document.querySelector("[data-layer-meta]");
    if (title) title.textContent = layer.title;
    if (body) body.textContent = layer.body;
    if (meta) {
      meta.innerHTML = layer.meta.map(([k, v]) => `<dt>${k}</dt><dd>${v}</dd>`).join("");
    }
    document.querySelectorAll(".slip .field").forEach((field) => {
      field.classList.toggle("sealed", layer.seal.includes(field.dataset.field));
    });
  }

  document.addEventListener("click", (event) => {
    const langBtn = event.target.closest(".lang button");
    if (langBtn) {
      apply(langBtn.dataset.lang);
      return;
    }
    const layerBtn = event.target.closest("[data-layer]");
    if (layerBtn) {
      const host = document.querySelector("[data-layers]");
      host.dataset.current = layerBtn.dataset.layer;
      renderLayers();
      return;
    }
    const menu = event.target.closest("[data-menu]");
    if (menu) {
      document.querySelector(".nav-links").classList.toggle("open");
    }
  });

  apply(lang);
})();
