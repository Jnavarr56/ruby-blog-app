
//PARTICLE BACKGROUND---------------------------------------------
particlesJS("particles-js", {"particles":{"number":{"value":7,"density":{"enable":true,"value_area":800}},"color":{"value":"#396afc"},"shape":{"type":"polygon","stroke":{"width":0,"color":"#000"},"polygon":{"nb_sides":6},"image":{"src":"img/github.svg","width":100,"height":100}},"opacity":{"value":0.6,"random":true,"anim":{"enable":false,"speed":1,"opacity_min":0.2,"sync":false}},"size":{"value":100,"random":false,"anim":{"enable":true,"speed":7,"size_min":40,"sync":false}},"line_linked":{"enable":false,"distance":200,"color":"#ffffff","opacity":1,"width":2},"move":{"enable":true,"speed":8,"direction":"none","random":false,"straight":false,"out_mode":"out","bounce":false,"attract":{"enable":false,"rotateX":600,"rotateY":1200}}},"interactivity":{"detect_on":"canvas","events":{"onhover":{"enable":false,"mode":"grab"},"onclick":{"enable":true,"mode":"push"},"resize":true},"modes":{"grab":{"distance":400,"line_linked":{"opacity":1}},"bubble":{"distance":400,"size":40,"duration":2,"opacity":8,"speed":3},"repulse":{"distance":200,"duration":0.4},"push":{"particles_nb":4},"remove":{"particles_nb":2}}},"retina_detect":true});
//----------------------------------------------------------------

//LOG OUT BUTTON--------------------------------------------------
document.getElementById("logOut").addEventListener("click", ()=>{
    axios.post('/log-out', {
        logout: "logout"
      })
      .then(function (response) {
          console.log(response);
          if (response.data.command === "logging out") {
              window.location = "/"
          }
    });
});
//----------------------------------------------------------------

//DISPLAY LAST TIMES IN LOCAL FORMAT------------------------------
document.addEventListener("DOMContentLoaded", ()=> {
    let op = 0;
    let fadeIn = setInterval(()=>{
        op += .025;
        document.body.style.opacity = `${op}`;
        if (op >= 1) {
            clearInterval(fadeIn);
        }
    },10);
});
//----------------------------------------------------------------



document.getElementById("newPostStartButton").addEventListener("click", ()=> {
    if (document.getElementById("newPostStartButton").innerHTML === "Follow") {
        let sure = confirm("Are you sure you want to follow this user?");
        if (sure) {
            axios.post('/follow', {
                user_to_follow: document.getElementById("newPostStartButton").getAttribute("data-user"),
                command: "FOLLOW"
              })
              .then((response) => {
                location.reload();
            });
        }
        else {
            return;
        }
    }
    else {
        let sure = confirm("Are you sure you want to unfollow this user?");
        if (sure) {
            axios.post('/follow', {
                user_to_unfollow: document.getElementById("newPostStartButton").getAttribute("data-user"),
                command: "UNFOLLOW"
              })
              .then((response) => {
                location.reload();
            });
        }
        else {
            return;
        }
    }
});







