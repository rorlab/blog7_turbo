// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails";
import "controllers";

// Turbo.session.drive = false;

document.addEventListener("turbo:before-stream-render", (event) => {
  const action = event.target.action;
  const targetFrame = document.getElementById(event.target.target);
  if (action === "remove") {
    let streamExitClass = targetFrame.dataset.animateOut;
    if (streamExitClass) {
      event.preventDefault();
      targetFrame.classList.add(streamExitClass);
      targetFrame.addEventListener("animationend", function () {
        event.target.performAction();
      });
    }
  } else if (action === "prepend" || action === "append") {
    if (event.target.firstElementChild instanceof HTMLTemplateElement) {
      let enterAnimationClass =
        event.target.templateContent.firstElementChild.dataset.animateIn;
      if (enterAnimationClass) {
        event.target.templateElement.content.firstElementChild.classList.add(
          enterAnimationClass
        );
      }
    }
  }
});
