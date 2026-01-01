let currentPlate = null;
let currentHash = null;
window.addEventListener('message', function(event) {
    let data = event.data;
    if (data.action === "open") {
        currentPlate = data.plate;
        document.getElementById("wrapper").style.display = "block";
        let list = document.getElementById("list");
        list.innerHTML = ""; 
        data.engines.forEach(eng => {
            let btn = document.createElement("div");
            btn.className = "item";
            btn.innerHTML = `<span>${eng.label}</span>`;
            btn.onclick = function() {
                currentHash = eng.hash;
                document.getElementById("wrapper").style.display = "none";
                document.getElementById("test-ui").style.display = "block";
                
                fetch(`https://${GetParentResourceName()}/testEngine`, {
                    method: 'POST',
                    headers: {'Content-Type': 'application/json'},
                    body: JSON.stringify({hash: eng.hash})
                });
            };
            list.appendChild(btn);
        });
    } else if (data.action === "closeUI") {
        hideAll();
    }
});
function hideAll() {
    document.getElementById("wrapper").style.display = "none";
    document.getElementById("test-ui").style.display = "none";
    currentHash = null;
    currentPlate = null;
}
function resetDefault() {
    fetch(`https://${GetParentResourceName()}/resetToDefault`, {
        method: 'POST',
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: JSON.stringify({ plate: currentPlate })
    }).then(resp => {
        hideAll();
    });
}
function sendConfirm() {
    fetch(`https://${GetParentResourceName()}/confirm`, {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({plate: currentPlate, hash: currentHash})
    });
    hideAll();
}
function sendCancel() {
    hideAll();
    fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({})
    });
}
function closeUI() {
    hideAll();
    fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({})
    });
}