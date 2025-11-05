# 🏦 KipuBank v2 – Smart Contract Mejorado

[![Solidity](https://img.shields.io/badge/Solidity-0.8.x-blue?logo=ethereum&logoColor=white)](https://soliditylang.org/)  
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

---

## 📖 Descripción

**KipuBankV2** es una evolución del contrato bancario descentralizado KipuBank, orientada a la seguridad y cercano a una aplicación DeFi real.  
Permite a los usuarios **depositar y retirar ETH o USDC**, integrando un **límite global basado en USD** que se actualiza dinámicamente con el precio de ETH/USD mediante **Chainlink**.

---

## 🚀 Mejoras Realizadas

| Mejora | Descripción |
|--------|-------------|
| 💱 **Soporte Multi-Token** | Depósitos y retiros tanto en `ETH` como en `USDC`. |
| 💵 **Límite Dinámico (USD)** | El límite se basa en el valor real en dólares utilizando oráculos de `Chainlink`. |
| 🔐 **Seguridad Mejorada** | Implementación de `ERC20` y `Ownable` de OpenZeppelin. |
| 🧩 **Mocks Locales** | `Circle.sol` (token USDC simulado) y `Oracle.sol` (precio ETH/USD simulado). |
| ⚙️ **Eventos Uniformes** | Unificación de eventos de depósito y retiro para ETH y USDC. |
| 🛡️ **Protección contra Reentrancy** | Evita ataques de reentrada durante retiros. |

---

## ⚙️ Despliegue

### 🔹 Pruebas Locales (Remix VM)
1. Desplegar `Circle.sol` (token USDC de prueba).  
2. Desplegar `Oracle.sol` (oráculo simulado que devuelve un precio fijo ETH/USD.).  
3. Desplegar `KipuBankV2`, pasando las direcciones de ambos contratos y el límite en USD.
   - Constructor:
     ```solidity
     constructor(address _priceFeedAddress, address _usdcTokenAddress, uint256 _bankCapUSD)
     ```
     - `_priceFeedAddress`: dirección del contrato `Oracle`.
     - `_usdcTokenAddress`: dirección del contrato `Circle`.
     - `_bankCapUSD`: límite de depósito global expresado en USD (por ejemplo `10000` = $10,000).  
4. Probar funciones de depósito, retiro y consulta de saldos.

---

### 🔹 Despliegue en Testnet (Sepolia)

**🧭 Dirección del contrato:**  
`0x7478bbD7Bb2C64A392b937b592CE8f8DDCc48362`

**📜 Dirección del contrato en etherscan:**  
[https://sepolia.etherscan.io/address/0x347E546F9Be5A6096B366248B8a04B52D84865E2](https://sepolia.etherscan.io/address/0x347E546F9Be5A6096B366248B8a04B52D84865E2)

**💻 Repositorio:**  
[https://github.com/michelmassaad/KipuBankV2.git](https://github.com/michelmassaad/KipuBankV2.git)

**📥 Parámetros del constructor:**
```solidity
_priceFeedAddress = 0x694AA1769357215DE4FAC081bf1f309aDC325306 // Chainlink ETH/USD Sepolia
_usdcTokenAddress = dirección del contrato Circle deployado en Sepolia
_bankCapUSD = límite en USD (ej: 10000)
````

---

## 💰 Interacción con el Contrato

### 🟢 Depósitos y 🔴 Retiros

| Activo | Función | Descripción |
|--------|----------|-------------|
| ETH | `depositEth()` | Envía ETH directamente al contrato (usar campo “Value” en Remix). |
| ETH | `withdrawalEth(uint256 amount)` | Retira ETH disponible. |
| USDC | `depositUSDC(uint256 amount)` |Requiere aprobación previa en el contrato Circle (approve(KipuBankV2, amount)). |
| USDC | `withdrawalUSDC(uint256 amount)` | Retira USDC disponible. |

**💡 Para depositar USDC:**
1. En el contrato del token (`Circle`), llamar a `approve(KipuBankV2, amount)`.  
2. Luego, en `KipuBankV2`, ejecutar `depositUSDC(amount)`.

---

### 📊 Consultas Útiles

| Función | Retorna | Descripción |
|----------|----------|-------------|
| `getBalances(address user)` | `(uint256 eth, uint256 usdc)` | Devuelve los saldos del usuario. |
| `getEthValueInUSD(uint256 ethAmount)` | `uint256` | Convierte ETH a su valor equivalente en USD según Chainlink. |

---

## 🔔 Eventos

| Evento | Parámetros | Descripción |
|---------|-------------|-------------|
| `Deposit(address indexed user, string indexed usdcOrEth, uint256 amount)` | Usuario, tipo de token, monto | Emite cuando se realiza un depósito exitoso. |
| `Withdrawal(address indexed user, string indexed usdcOrEth, uint256 amount)` | Usuario, tipo de token, monto | Emite cuando se realiza un retiro exitoso. |

---

## 🔒 Seguridad y Buenas Prácticas

- Patrón **Checks → Effects → Interactions** implementado en funciones críticas.
- Protección anti-reentrancy mediante flag `locked`.
- Validaciones de montos (nonZeroAmount, InsufficientBalance, etc.).
- Errores personalizados para feedback claro y menor uso de gas.
- Librerías **OpenZeppelin** para estandarización (Ownable, ERC20).

---

## ✉️ Autor

👤 **Michel Massaad**
📫 [GitHub – michelmassaad](https://github.com/michelmassaad)




