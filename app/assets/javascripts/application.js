document.addEventListener("DOMContentLoaded", () => {
    const flashMessages = document.querySelectorAll(".flash-message");
  
    flashMessages.forEach((message) => {
      setTimeout(() => {
        message.style.transition = "opacity 0.5s ease";
        message.style.opacity = "0";
        setTimeout(() => {
          message.remove();
        }, 500);
      }, 1500);
    });
  });