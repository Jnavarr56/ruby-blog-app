
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
    for (let x = 0; x < document.getElementsByClassName("accountChangeCheckBox").length; x++) {
        document.getElementsByClassName("accountChangeCheckBox")[x].addEventListener("change", ()=>{
            if (document.getElementsByClassName("accountChangeCheckBox")[x].previousElementSibling.getAttribute("disabled")) {
                document.getElementsByClassName("accountChangeCheckBox")[x].previousElementSibling.removeAttribute("disabled");
                document.getElementsByClassName("accountChangeCheckBox")[x].previousElementSibling.setAttribute("placeholder", "");
            }
            else {
                document.getElementsByClassName("accountChangeCheckBox")[x].previousElementSibling.setAttribute("disabled", true);
                document.getElementsByClassName("accountChangeCheckBox")[x].previousElementSibling.value = "";
                document.getElementsByClassName("accountChangeCheckBox")[x].previousElementSibling.setAttribute("placeholder", "DO NOT CHANGE");
            }
        });
    }
    let op = 0;
    let fadeIn = setInterval(()=>{
        op += .025;
        document.body.style.opacity = `${op}`;
        if (op >= 1) {
            clearInterval(fadeIn);
        }
    },10);

    for (let x = 0; x < document.getElementsByClassName("deletePostButton").length; x++) {
        document.getElementsByClassName("deletePostButton")[x].addEventListener("click", ()=>{
            let confirmPostDelete = confirm("Are you sure you want to delete this post?");
            if (confirmPostDelete) {
                axios.post('/posts-portal', {
                    command: "DELETE",
                    post_to_delete: parseInt(document.getElementsByClassName("deletePostButton")[x].id)
                    
                  })
                  .then((response) => {
                    location.reload();
                });
            }
        });
    }

    for (let x = 0; x < document.getElementsByClassName("updatePostButton").length; x++) {
        document.getElementsByClassName("updatePostButton")[x].addEventListener("click", ()=>{
            if (document.getElementsByClassName("updatePostButton")[x].innerHTML === "Edit Post") {
                document.getElementsByClassName("updatePostButton")[x].innerHTML = "Submit";
                document.getElementsByClassName("updatePostButton")[x].parentElement.children[1].disabled = false;
                document.getElementsByClassName("updatePostButton")[x].parentElement.children[1].style.backgroundColor = "orange";

                for (let y = 1; y < document.getElementsByTagName("textarea").length; y++) {
                    if (document.getElementsByClassName("updatePostButton")[x].parentElement.children[1] !== document.getElementsByTagName("textarea")[y]) {
                        document.getElementsByTagName("textarea")[y].disabled = true;
                        document.getElementsByTagName("textarea")[y].style.backgroundColor = "";
                        document.getElementsByTagName("textarea")[y].parentElement.children[3].innerHTML = "Edit Post";
                        
                    }
                }
            }
            else {
                let updatePostDelete = confirm("Are you sure you want to update this post?");
                if (updatePostDelete) {
                    axios.post('/posts-portal', {
                        command: "UPDATE",
                        post_to_update: parseInt(document.getElementsByClassName("updatePostButton")[x].id),
                        new_content: document.getElementsByClassName("updatePostButton")[x].parentElement.children[1].value,
                      })
                      .then((response) => {
                        location.reload();
                    });
                }
            }

        });
    }

});
//----------------------------------------------------------------

//----UPDATE/DELETE ACCOUNT MODAL TOGGLING-------------------------
//TOGGLE MODAL WITH DASHBOARD BUTTON
document.getElementById("editAccountInfoButton").addEventListener("click", ()=>{
    if (document.getElementById("accountChangeForm").style.display === "flex") {
        document.getElementById("accountChangeForm").style.display = "none";
    }
    else  {
        document.getElementById("accountChangeForm").style.display = "flex";
    }
});
//TOGGLE MODAL WITH MODAL BUTTON
document.getElementById("closeAccountChangeModalButton").addEventListener("click", ()=>{
    document.getElementById("accountChangeForm").style.display = "none";
});
//----------------------------------------------------------------

//SUBMIT UPDATE ACCOUNT FORM FOR FIELD UPDATES--------------------
document.getElementById("accountChangeFormButton").addEventListener("click", ()=>{
    event.preventDefault();
    for (let x = 0; x < document.getElementsByClassName("accountChangeCheckBox").length; x++) {
        if (!document.getElementsByClassName("accountChangeCheckBox")[x].previousElementSibling.getAttribute("disabled") && document.getElementsByClassName("accountChangeCheckBox")[x].previousElementSibling.value === "") {
            alert("All checked fields must be filled out.")
            return;
        }
        if (!document.getElementsByClassName("accountChangeCheckBox")[x].previousElementSibling.getAttribute("disabled") && document.getElementsByClassName("accountChangeCheckBox")[x].previousElementSibling.id === "newUsernameInput") {
            if (!isValidEmail(document.getElementsByClassName("accountChangeCheckBox")[x].previousElementSibling.value)) {
                alert("Invalid email/username input.");
                return;
            }
        }
    }
    if (document.getElementById("passwordInput").value === "") {
        alert("Current password required");
        return;
    }
    let sendNewAccountPackage = {};
    for (let x = 0; x < document.getElementsByClassName("newFieldInput").length; x++) {
        sendNewAccountPackage[document.getElementsByClassName("newFieldInput")[x].id] = document.getElementsByClassName("newFieldInput")[x].value.trim();
    }
    let accountChangeConfirmation = confirm("Are you sure you want to make these changes?");
    if (accountChangeConfirmation) {
        axios.post('/update-account-portal', sendNewAccountPackage
        ).then((response) => {
            console.log(response);
            if (response.data.code === "USERNAME TAKEN") {
                alert("An account with this username already exists.");
                return;
            }
            if (response.data.code === "CURRENT PASSWORD INCORRECT") {
                alert("Current password is incorrect.");
                return;
            }
            if (response.data.code === "USERNAME AVAILABLE") {
                document.getElementById("logOut").click();
            }
        });
    }
});
//----------------------------------------------------------------


//-----SUBMIT DELETION OF ACCOUNT----------------------------------
document.getElementById("accountDeleteFormButton").addEventListener("click", ()=>{
    event.preventDefault();
    if (document.getElementById("passwordInput").value === "") {
        alert("Current password required for this change.");
        return;
    }
    let really = confirm("Are you sure you want to delete your account?");
    if (!really) {
        return;
    }

    axios.post('/delete-account-portal', {
            passwordInput: document.getElementById("passwordInput").value
        }).then((response) => {
            console.log(response);
            if (response.data.code === "PASSWORD INCORRECT") {
                alert("Current password is incorrect.");     
            }
            else  {
                document.getElementById("logOut").click();
            }
    });
});
//----------------------------------------------------------------

//------TOGGLE POST EDITOR----------------------------------------
document.getElementById("newPostStartButton").addEventListener("click", ()=>{
    togglePostEditor();
});
//----------------------------------------------------------------

//-----SUBMIT POST------------------------------------------------
document.getElementById("submitNewPostButton").addEventListener("click", ()=>{
    if (document.getElementById("newPostContentInput").value === "") {
        alert("Cannot submit an empty post.");
        return;
    }
    if (document.getElementById("newPostTitleInput").value === "") {
        alert("Post must have title.");
        return;
    }

    let confirmPost = confirm("Are you sure you want to post this?");
    if (!confirmPost) {
        return; 
    }

    let userAddedTags = [];
    for (let x = 0; x < document.getElementsByClassName("newPostTags").length; x++) {
        if (document.getElementsByClassName("newPostTags")[x].checked) {
            userAddedTags.push(document.getElementsByClassName("newPostTags")[x].value);
        }
    }
    console.log(userAddedTags);
    if (userAddedTags.length > 0) {
        axios.post('/posts-portal', {
            post_title: document.getElementById("newPostTitleInput").value,
            post_content: document.getElementById("newPostContentInput").value,
            command: "CREATE",
            user_added_tags: userAddedTags
          })
          .then((response) => {
            if (response.data.code === "POST ADDED" || response.data.code === "POST ADDED WITH TAGS") {
                location.reload();
            }
        });
    }
    else {
        axios.post('/posts-portal', {
            post_title: document.getElementById("newPostTitleInput").value,
            post_content: document.getElementById("newPostContentInput").value,
            command: "CREATE",
          })
          .then((response) => {
              if (response.data.code === "POST ADDED" || response.data.code === "POST ADDED WITH TAGS") {
                location.reload();
              }
        });
    }
});
//----------------------------------------------------------------

//FILTER POSTS----------------------------------------------------
document.getElementById("filterButtonGo").addEventListener("click", ()=>{
    if (document.getElementById("postMasterWrapper").children.length > 2) {
        let checkedTags = [];
        for (let x = 0 ; x < document.getElementsByClassName("hashOptionsWrapper").length; x++) {
            if (document.getElementsByClassName("hashOptionsWrapper")[x].children[1].checked) {
                checkedTags.push(document.getElementsByClassName("hashOptionsWrapper")[x].firstElementChild.innerText);
            }
        }

        if (checkedTags.length === 0) {
            for (let x = 0; x < document.getElementsByClassName("postWrapper").length; x++) {
                document.getElementsByClassName("postWrapper")[x].style.visibility = "visibile";
            }    
        }

        console.log(checkedTags);
        
        for (let x = 0; x < document.getElementsByClassName("postWrapper").length; x++) {
            let shouldHide = 0;
            for (let y = 0; y < checkedTags.length; y++) {
                console.log(document.getElementsByClassName("postWrapper")[x].children[5].innerHTML.replace("Tags:", "").replace(/[""]/g, "").split(",").map(x => x.trim()));
                if (document.getElementsByClassName("postWrapper")[x].children[5].innerHTML.replace("Tags:", "").replace(/[""]/g, "").split(",").map(x => x.trim()).includes(checkedTags[y])) {
                    shouldHide ++;
                }
            }
            console.log(shouldHide);
            if (shouldHide !== checkedTags.length) {
                document.getElementsByClassName("postWrapper")[x].style.display = "none";
            }
            else {
                document.getElementsByClassName("postWrapper")[x].style.display = "flex";
            }
        }
    }
    else {
        alert("Cannot filter posts that do not exist.");
    }
});
//----------------------------------------------------------------


//FUNCTIONS-----------------------------------------------------
let displayTimes = () => {
    //Display Created Date
    let rawDateCreatedDate = document.getElementById("createdDate").innerText;
    let convertedCreatedDate = new Date(rawDateCreatedDate);
    document.getElementById("createdDate").innerText = `Member Since: ${convertedCreatedDate.toLocaleDateString()}`;

          
    //Display Last Online
    let rawDateLastActive = document.getElementById("lastActive").innerText;
    let convertedDateActive = new Date(rawDateLastActive);
    document.getElementById("lastActive").innerText = `Last Online: ${convertedDateActive.toLocaleString()}`;
}
let isValidEmail = (emailStr) =>{
    return /^.+@.+\..+$/.test(emailStr);
}
let togglePostEditor = () => {
    if (document.getElementById("newPostEditorWrapper").style.height !== "500px") {
        document.getElementById("newPostEditorWrapper").classList.add("expandPostEditor");
        document.getElementById("newPostStartButton").innerHTML = "Cancel New Post";
        document.getElementById("newPostStartButton").style.backgroundColor = "red";
        document.getElementById("newPostStartButton").style.color = "white";
        setTimeout(()=>{
            document.getElementById("newPostEditorWrapper").classList.remove("expandPostEditor");
            document.getElementById("newPostEditorWrapper").style.height = "500px";
        },500);
    }
    else {
        if (document.getElementById("newPostContentInput").value !== "") {
            let discardSure = confirm("Are you sure you want to discard this post?");
            if (!discardSure) {  
                return;
            }
            else {
                document.getElementById("newPostContentInput").value = "";
            } 
        }
        document.getElementById("newPostEditorWrapper").classList.add("collapsePostEditor");
        document.getElementById("newPostStartButton").innerHTML = "New Post";
        document.getElementById("newPostStartButton").style.backgroundColor = "white";
        document.getElementById("newPostStartButton").style.color = "black";
        setTimeout(()=>{
            document.getElementById("newPostEditorWrapper").classList.remove("collapsePostEditor");
            document.getElementById("newPostEditorWrapper").style.height = "0px";
        },500);
    }
}



