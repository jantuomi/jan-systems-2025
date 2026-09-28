const b = document.createElement("button");
b.innerHTML = "🌓";
b.setAttribute("id", "dark-mode-btn");
b.setAttribute("aria-label", "Toggle dark mode");
document.querySelector("#dark-mode-btn").replaceWith(b);

const initialManualColorScheme =
  localStorage.getItem("colorScheme");
// If null, no manual color scheme is set
if (initialManualColorScheme === "dark") {
  document.body.parentElement.classList.add("dark");
} else if (initialManualColorScheme === "light") {
  document.body.parentElement.classList.add("light");
}

function getCurrentManualColorScheme() {
  if (document.body.parentElement.classList.contains("dark"))
    return "dark";
  if (document.body.parentElement.classList.contains("light"))
    return "light";
  return null;
}

document
  .querySelector("#dark-mode-btn")
  .addEventListener("click", function () {
    const manualColorScheme = getCurrentManualColorScheme();
    const userPreferenceIsDark =
      window.matchMedia &&
      window.matchMedia("(prefers-color-scheme: dark)")
        .matches;

    const currentColorScheme =
      manualColorScheme ??
      (userPreferenceIsDark ? "dark" : "light");
    const newColorScheme =
      currentColorScheme === "dark" ? "light" : "dark";

    document.body.parentElement.classList.remove(
      "dark",
      "light",
    );
    document.body.parentElement.classList.add(newColorScheme);

    localStorage.setItem("colorScheme", newColorScheme);
  });
