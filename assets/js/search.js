(function () {
  function update(hash) {
    let tag = unescape(location.hash.slice(1) || "");
    let content = document.querySelector("#content");
    content.dataset.filter = tag;
  }

  window.addEventListener("hashchange", update);
  window.addEventListener("load", update);
})();
