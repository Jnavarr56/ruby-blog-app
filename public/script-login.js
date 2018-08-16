//FOCUS ON INPUT UPON LOADING-----------------------------------------------------------------------------------
window.onload = ()=> {
    document.getElementsByTagName("input")[0].focus();
};
//RESPOSIBLE FOR PARTICLE BACKGROUND----------------------------------------------------------------------------
particlesJS("particles-js", {"particles":{"number":{"value":110,"density":{"enable":true,"value_area":800}},"color":{"value":"#ffffff"},"shape":{"type":"circle","stroke":{"width":0,"color":"#000000"},"polygon":{"nb_sides":5},"image":{"src":"img/github.svg","width":100,"height":100}},"opacity":{"value":.8,"random":false,"anim":{"enable":false,"speed":1,"opacity_min":0.1,"sync":false}},"size":{"value":3,"random":true,"anim":{"enable":false,"speed":40,"size_min":0.1,"sync":false}},"line_linked":{"enable":true,"distance":150,"color":"#ffffff","opacity":1,"width":1},"move":{"enable":true,"speed":6,"direction":"none","random":false,"straight":false,"out_mode":"out","bounce":false,"attract":{"enable":false,"rotateX":600,"rotateY":1200}}},"interactivity":{"detect_on":"canvas","events":{"onhover":{"enable":false,"mode":"repulse"},"onclick":{"enable":true,"mode":"push"},"resize":true},"modes":{"grab":{"distance":400,"line_linked":{"opacity":.7}},"bubble":{"distance":400,"size":40,"duration":2,"opacity":8,"speed":3},"repulse":{"distance":200,"duration":0.4},"push":{"particles_nb":4},"remove":{"particles_nb":2}}},"retina_detect":true});
//TYPEWRITER EFFECT FOR MENU TITLE----------------------------------------------------------------------------
let captionsArray = ["learn.     connect.     share.              ", "private blogging for activist developers.             ", "resist.io                                     "];
let phrase = 0;
let char = 0;
let type = setInterval(()=>{
    document.getElementById("title").innerHTML += captionsArray[phrase][char];
    char++;
    if (char === captionsArray[phrase].length) {
        char = 0;
        phrase ++;
        document.getElementById("title").innerHTML = "";
        if (phrase > 2) {
            phrase = 0;
        }
    }
}, 50);
//TOGGLE BETWEEN SIGN UP OR LOGIN----------------------------------------------------------------------------
document.getElementById("signUpButton").addEventListener("click", (event)=>{
    clearInterval(type);
    event.preventDefault();
    if (!document.getElementById("mainForm").classList.contains("shrinkGrow")) {
        document.getElementById("title").innerHTML = "";
        document.getElementById("mainForm").classList.remove("growShrink");
        document.getElementById("mainForm").classList.add("shrinkGrow");
        document.getElementsByTagName("button")[0].style.display = "none";
        document.getElementsByTagName("button")[1].style.display = "none";
        document.getElementById("loginFields").classList.add("swapOutLogIn");
        document.getElementById("loginFields").classList.remove("swapInLogIn");
        document.getElementById("signUpFields").classList.add("swapInSignUp");
        document.getElementById("signUpFields").classList.remove("swapOutSignUp");
        setTimeout(()=>{
            document.getElementById("title").innerHTML = "sign up.";
            document.getElementsByTagName("button")[0].innerHTML = "create account";
            document.getElementsByTagName("button")[1].innerHTML = "return to log in";
            document.getElementsByTagName("button")[0].style.display = "initial";
            document.getElementsByTagName("button")[1].style.display = "initial";
        },2000);
    }
    else {
        document.getElementById("mainForm").classList.remove("shrinkGrow");
        document.getElementById("mainForm").classList.add("growShrink");
        document.getElementById("title").innerHTML = "";
        document.getElementsByTagName("button")[0].style.display = "none";
        document.getElementsByTagName("button")[1].style.display = "none";
        document.getElementById("signUpFields").classList.add("swapOutSignUp");
        document.getElementById("signUpFields").classList.remove("swapInSignUp");
        document.getElementById("loginFields").classList.remove("swapOutLogIn");
        document.getElementById("loginFields").classList.add("swapInLogIn");
        setTimeout(()=>{
            document.getElementById("title").innerHTML = "log in.";
            document.getElementsByTagName("button")[0].innerHTML = "go";            
            document.getElementsByTagName("button")[1].innerHTML = "sign up";
            document.getElementsByTagName("button")[0].style.display = "initial";
            document.getElementsByTagName("button")[1].style.display = "initial";
        },2000);
    }
});
//TOGGLE HIDE OR SHOW OF PASSWORD-------------------------------------------------------------------------------
document.getElementById("togglePassword").addEventListener("change", ()=>{
    if (document.getElementById("pwd").getAttribute("type") === "password") {
        document.getElementById("pwd").setAttribute("type", "text");
    }
    else {
        document.getElementById("pwd").setAttribute("type", "password");
    }
});
//ATTEMPT A LOGIN WITH A POST REQUEST OR ATTEMPT A SIGN UP WITH A POST REQUEST---------------------------------
document.getElementById("goButton").addEventListener("click", (event)=>{
    event.preventDefault();
    if (document.getElementById("goButton").innerHTML === "go") { //<---try log in and return shake animation if no match
        axios.post('/login-data-portal', {
            usernameInput: document.getElementById("username_input").value,
            passwordInput: document.getElementById("pwd").value
          })
          .then(function (response) {
            if (response.data.error === "ERROR") {
                shakeLogIn("wrong");
                console.log(response);
            }
            else if (response.data.error === "ERROR NOT VERIFIED") {
                shakeLogIn("unverified");
                console.log(response);
            }
            else if (response.data.error === "NO ERROR"){
                console.log(response);
                window.location = "/dashboard"
            }
          });
    }
    else {
        let signUpInputs = [document.getElementById("dob"), document.getElementById("new_username"), document.getElementById("new_password")];
        if (document.getElementById("dob").value  === "" || document.getElementById("new_username").value  === "" || document.getElementById("new_password").value  === "") { //<---validate sign up inputs
            document.getElementById("title").innerHTML = "all fields must be filled out.";
            for (let x = 0; x < signUpInputs.length; x++) {
                if (signUpInputs[x].value === "") {
                    signUpInputs[x].previousElementSibling.classList.add("leftEmpty");
                    setTimeout(()=>{
                        signUpInputs[x].previousElementSibling.classList.remove("leftEmpty");
                    }, 1000);
                }
            }  
        }
        else {
            if (((new Date()).getFullYear() - parseInt(document.getElementById("dob").value.slice(0,4))) < 18) {
                document.getElementById("title").innerHTML = "you must be at least 18 to sign up.";
                document.getElementById("dob").previousElementSibling.classList.add("leftEmpty");
                setTimeout(()=>{
                    document.getElementById("dob").previousElementSibling.classList.remove("leftEmpty");
                }, 1000);
            }
            else if (!isValidEmail(document.getElementById("new_username").value)) {
                document.getElementById("title").innerHTML = "invalid email.";
                document.getElementById("new_username").previousElementSibling.classList.add("leftEmpty");
                setTimeout(()=>{
                    document.getElementById("new_username").previousElementSibling.classList.remove("leftEmpty");
                }, 1000);
            }
            else {
                axios.post('/signup-data-portal', {
                    new_username_input: document.getElementById("new_username").value,
                    new_password_input: document.getElementById("new_password").value,
                    new_dob_input: document.getElementById("dob").value
                  })
                  .then(function (response) {
                      console.log(response);
                      if (response.data.code === "USERNAME TAKEN") {
                        document.getElementById("title").innerHTML = "an account with this username exists.";
                        document.getElementById("new_username").previousElementSibling.classList.add("leftEmpty");
                        setTimeout(()=>{
                            document.getElementById("new_username").previousElementSibling.classList.remove("leftEmpty");
                        }, 1000);
                      }
                      else if (response.data.code === "USERNAME FREE, PROCEDE") {
                        document.getElementById("title").innerHTML = "please verify your email.";
                      }
                });
            }
        }
        
    }
});













//--------------------------------------------------
let shakeLogIn = (str) =>{
    clearInterval(type);
    if (str === "wrong") {
        document.getElementById("title").innerHTML = "We don't recognize this username/password combination.<br>Try signing up?";
    }
    else {
        document.getElementById("title").innerHTML = "please verify email.";
    }
    
    document.getElementById("loginFields").classList.add("shakeLogIn");
    document.getElementById("loginFields").classList.remove("swapInLogIn");
    setTimeout(()=>{
        document.getElementById("loginFields").classList.remove("shakeLogIn");
    },250);
    setTimeout(()=>{
        document.getElementById("title").innerHTML = "log in."
    },4000);
}

let isValidEmail = (emailStr) =>{
    return /^.+@.+\..+$/.test(emailStr);
}

