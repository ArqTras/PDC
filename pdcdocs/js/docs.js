(function () {
  var input = document.querySelector(".search");
  var links = Array.prototype.slice.call(document.querySelectorAll(".nav-group a"));
  if (input) {
    input.addEventListener("input", function () {
      var q = input.value.trim().toLowerCase();
      links.forEach(function (link) {
        var group = link.parentElement;
        var show = !q || link.textContent.toLowerCase().indexOf(q) !== -1;
        link.hidden = !show;
        if (group) group.hidden = !group.querySelector("a:not([hidden])");
      });
    });
  }
  var menu = document.querySelector("[data-menu]");
  var side = document.querySelector(".sidebar");
  var backdrop = document.querySelector("[data-backdrop]");
  function setOpen(open) {
    if (!side) return;
    side.classList.toggle("open", open);
    if (backdrop) backdrop.hidden = !open;
    if (menu) menu.setAttribute("aria-expanded", open ? "true" : "false");
  }
  if (menu) menu.addEventListener("click", function () { setOpen(!side.classList.contains("open")); });
  if (backdrop) backdrop.addEventListener("click", function () { setOpen(false); });
  document.querySelectorAll(".sidebar a").forEach(function (link) {
    link.addEventListener("click", function () { setOpen(false); });
  });
})();
