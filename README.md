# 🏦 KipuBank v2 – Smart Contract Mejorado

[![Solidity](https://img.shields.io/badge/Solidity-0.8.x-blue?logo=ethereum&logoColor=white)](https://soliditylang.org/)  
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

---

## 📘 Descripción general

**KipuBank v2** es la versión mejorada del contrato bancario desarrollado en Solidity.  
Este smart contract permite realizar **depósitos y retiros tanto en ETH como en USDC**, con control de límites, validaciones robustas y prácticas seguras de arquitectura.

La versión actual introduce **modularidad**, **compatibilidad multi-token**, y un manejo más profesional de **errores y eventos**, además de una separación clara entre la lógica de interacción con ETH y el control interno de balances.

---

## 🚀 Mejoras realizadas y motivos

| Mejora | Descripción | Motivo |
|--------|--------------|--------|
| ✅ **Soporte para múltiples activos (ETH / USDC)** | Ahora los depósitos y retiros pueden manejar distintos tokens. | Ampliar la funcionalidad y simular un banco real con diferentes divisas. |
| ✅ **Refactorización de eventos** | Se unifican los eventos de depósito y retiro: `Deposit(address, string, uint256)` y `Withdrawal(address, string, uint256)`. | Mejor trazabilidad y registro unificado. |
| ✅ **Función interna `_transferEth()`** | Centraliza la lógica de transferencia segura de ETH. | Evita duplicar código y mejora la legibilidad. |
| ✅ **Errores personalizados extendidos** | Añade nuevos errores como `WithdrawalFailed(bytes errorData)` y `BankCapExceeded()`. | Proporcionar feedback claro y controlado al usuario. |
| ✅ **Reentrancy Guard** | Protección reforzada contra ataques de reentrada. | Seguridad en las funciones críticas de retiro. |
| ✅ **Control de límites** | Se validan límites individuales (`withdrawalLimit`) y globales (`bankCap`). | Mantener la integridad financiera del contrato. |

---

## ⚙️ Instrucciones de despliegue

### 1. Requisitos previos
- [Remix IDE](https://remix.ethereum.org/)
- Cuenta de prueba en [MetaMask](https://metamask.io/)
- Fondos de testnet (ETH y/o USDC) en redes como Sepolia o Holesky

### 2. Despliegue paso a paso
1. Abrir Remix y crear el archivo `KipuBank.sol` en la carpeta `/contracts`.  
2. Copiar el código del contrato.  
3. Compilar con el compilador **Solidity 0.8.x**.  
4. En la pestaña **Deploy & Run Transactions**, seleccionar:
   - **Environment:** "Injected Provider - MetaMask"
   - **Account:** tu dirección de MetaMask
   - **Gas limit:** suficiente para la transacción (~3M)
5. Configurar el **constructor** con los siguientes parámetros:
   - `_withdrawalLimit`: límite máximo de retiro por transacción (en wei).
   - `_bankCap`: límite total de fondos permitidos (en wei).
6. Hacer clic en **Deploy**.
7. Verificar el contrato en el block explorer (por ejemplo, [Etherscan](https://sepolia.etherscan.io/)).

📄 **Ejemplo de dirección desplegada:**  
`0xa31d41b22440fd2651Ace76E5b0202c20f16d047`  
📁 **Repositorio:** [https://github.com/michelmassaad/kipu-bank](https://github.com/michelmassaad/kipu-bank)

---

## 🧠 Interacción con el contrato

### Funciones principales

| Función | Tipo | Descripción |
|----------|------|-------------|
| `deposit()` | `external payable` | Permite depositar ETH al contrato (usa `msg.value`). |
| `depositUsdc(uint256 amount)` | `external` | Permite depositar USDC (requiere aprobación previa del token). |
| `withdrawal(uint256 amount)` | `external` | Retira ETH del balance del usuario hasta el límite permitido. |
| `withdrawalUsdc(uint256 amount)` | `external` | Retira USDC del balance del usuario. |
| `getBalance(address account)` | `external view` | Devuelve el saldo del usuario en ETH. |
| `getUsdcBalance(address account)` | `external view` | Devuelve el saldo del usuario en USDC. |

---

## 🔔 Eventos

| Evento | Parámetros | Descripción |
|---------|-------------|-------------|
| `Deposit(address indexed user, string indexed usdcOrEth, uint256 amount)` | Usuario, tipo de token, monto | Emitido al realizar un depósito exitoso. |
| `Withdrawal(address indexed user, string indexed usdcOrEth, uint256 amount)` | Usuario, tipo de token, monto | Emitido al realizar un retiro exitoso. |

---

## 🧩 Ejemplo de uso (en Remix)

1. **Depósito de ETH**
   - En el campo **Value**, ingresar el monto en **wei** (por ejemplo `1000000000000000000` para 1 ETH).
   - Llamar a `deposit()`.
2. **Retiro de ETH**
   - Llamar a `withdrawal(amount)` con el valor en wei a retirar.
3. **Consultar balance**
   - Usar `getBalance(msg.sender)` para ver el saldo en ETH.
4. **Depósito y retiro de USDC**
   - Llamar primero al `approve()` del contrato del token USDC.
   - Luego ejecutar `depositUsdc(amount)` o `withdrawalUsdc(amount)`.

---

## 🧱 Decisiones de diseño y trade-offs

- Se priorizó **seguridad y claridad del flujo** sobre la eficiencia en gas.  
- El uso de `string` en los eventos (`usdcOrEth`) permite una lectura más legible, aunque incrementa ligeramente el costo de almacenamiento en logs.  
- El control de límites está pensado para **simulación educativa**, no para un entorno de producción real.  
- Se mantuvo una estructura modular (`_transferEth`) para permitir extender el contrato fácilmente hacia otros tokens ERC20.

---

## 🔒 Seguridad y buenas prácticas

- **Checks-Effects-Interactions** aplicado en funciones críticas.  
- **Reentrancy Guard** para evitar ataques de doble ejecución.  
- **Errores personalizados** para optimizar gas y claridad del código.  
- **Eventos estructurados** para trazabilidad completa de transacciones.

---

## 🧾 Licencia

Este proyecto está licenciado bajo la [MIT License](https://opensource.org/licenses/MIT).

---
