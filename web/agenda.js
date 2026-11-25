function abrirAgenda() {
  return new Promise((resolve, reject) => {
    const pedido = indexedDB.open("agenda_fatec", 1);
    pedido.onupgradeneeded = () => {
      pedido.result.createObjectStore("atividades", {keyPath: "id", autoIncrement: true});
    };
    pedido.onsuccess = () => resolve(pedido.result);
    pedido.onerror = () => reject(pedido.error);
  });
}

async function listarAgenda() {
  const banco = await abrirAgenda();
  try {
    return await new Promise((resolve, reject) => {
      const pedido = banco.transaction("atividades").objectStore("atividades").getAll();
      pedido.onsuccess = () => resolve(JSON.stringify(pedido.result));
      pedido.onerror = () => reject(pedido.error);
    });
  } finally {
    banco.close();
  }
}

async function salvarAgenda(texto) {
  const banco = await abrirAgenda();
  try {
    await new Promise((resolve, reject) => {
      const transacao = banco.transaction("atividades", "readwrite");
      transacao.objectStore("atividades").put(JSON.parse(texto));
      transacao.oncomplete = () => resolve();
      transacao.onabort = () => reject(transacao.error);
    });
  } finally {
    banco.close();
  }
}
