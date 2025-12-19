var atlasTab = document.getElementById("atlas-tab");
var localTab = document.getElementById("local-tab")
var atlasContent = document.getElementById("atlas-content");
var localContent = document.getElementById("local-content");

handleTabContent("atlas");

atlasTab.addEventListener("click", ()=>{
    handleTabContent("atlas");
});
localTab.addEventListener("click", ()=>{
    handleTabContent("local");
});

function handleTabContent(tabName){
    if(tabName === "atlas"){
        atlasContent.style.setProperty("display", "block")
        localContent.style.setProperty("display", "none")
        if(!atlasTab.classList.contains("is-active")){
            atlasTab.classList.add("is-active");
        }
        if(localTab.classList.contains("is-active")){
            localTab.classList.remove("is-active");
        }
    }
    else if(tabName === "local"){
        atlasContent.style.setProperty("display", "none")
        localContent.style.setProperty("display", "block")
        if(!localTab.classList.contains("is-active")){
            localTab.classList.add("is-active");
        }
        if(atlasTab.classList.contains("is-active")){
            atlasTab.classList.remove("is-active");
        }
    }
}