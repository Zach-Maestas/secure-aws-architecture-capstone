const API_BASE_URL = "https://api.zachmaestas-capstone.com/db"; // TODO: Check functionality after changing path

async function fetchItems() {
  const list = document.getElementById("item-list");
  list.innerHTML = "<li>Loading...</li>";
  try {
    const res = await fetch(`${API_BASE_URL}/items`);
    const data = await res.json();
    if (!data.items || data.items.length === 0) {
      list.innerHTML = "<li>No items found.</li>";
      return;
    }
    list.innerHTML = "";
    data.items.forEach(item => {
      const li = document.createElement("li");
      li.textContent = `${item.id}: ${item.name}`;
      const del = document.createElement("button");
      del.textContent = "Delete";
      del.className = "delete-btn";
      del.onclick = () => deleteItem(item.id);
      li.appendChild(del);
      list.appendChild(li);
    });
  } catch (err) {
    list.innerHTML = `<li>Error loading items: ${err}</li>`;
  }
}

document.getElementById("item-form").addEventListener("submit", async e => {
  e.preventDefault();
  const nameInput = document.getElementById("item-name");
  const name = nameInput.value.trim();
  if (!name) return alert("Please enter a name.");
  try {
    await fetch(`${API_BASE_URL}/items`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ name })
    });
    nameInput.value = "";
    fetchItems();
  } catch (err) {
    alert("Failed to add item: " + err);
  }
});

async function deleteItem(id) {
  if (!confirm("Delete this item?")) return;
  try {
    await fetch(`${API_BASE_URL}/items/${id}`, { method: "DELETE" });
    fetchItems();
  } catch (err) {
    alert("Failed to delete item: " + err);
  }
}

fetchItems();
