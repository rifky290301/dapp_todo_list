import 'dart:convert';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

class TodoService {
  final String rpcUrl = "http://127.0.0.1:7545"; // Ganti dengan URL Ganache atau testnet
  final String privateKey = "a34b850b98d1ed8bb9e681d62ceec8e826a161d8e53852ca60d3bb6686225cb3";
  final int chainId = 1337;

  late Web3Client _client;
  late String _abiCode;
  late EthereumAddress _contractAddress;
  late EthPrivateKey _credentials;
  late DeployedContract _contract;

  TodoService() {
    _client = Web3Client(rpcUrl, Client());
    _initialize();
  }

  Future<void> _initialize() async {
    _contractAddress = EthereumAddress.fromHex("0x873A80e7EcD5FfF9183dd0DDB6a8a2755b2d19C0"); // Alamat smart contract
    _credentials = EthPrivateKey.fromHex(privateKey);

    String abiString = await rootBundle.loadString("assets/TodoList.json");
    // Parse the raw JSON string into a Map
    final jsonAbi = jsonDecode(abiString);

    // Extract the 'abi' portion from the JSON
    _abiCode = jsonEncode(jsonAbi['abi']); // Convert it back to JSON string

    // Use the ABI to create a ContractAbi instance
    final contractAbi = ContractAbi.fromJson(_abiCode, "TodoList");
    _contract = DeployedContract(contractAbi, _contractAddress);
  }

  Future<void> createTask(String taskName) async {
    try {
      final createTaskFunction = _contract.function("createTask");

      // Dapatkan nonce secara manual
      final nonce = await _client.getTransactionCount(_credentials.address);

      await _client.sendTransaction(
        _credentials,
        Transaction.callContract(
          contract: _contract,
          function: createTaskFunction,
          parameters: [taskName],
          nonce: nonce.toInt(),
        ),
        chainId: chainId, // Pastikan chain ID sesuai
      );
    } catch (e) {
      log(e.toString());
    }
  }

  Future<int> getTaskCount() async {
    try {
      final getTaskCountFunction = _contract.function("getTaskCount");
      final result = await _client.call(
        contract: _contract,
        function: getTaskCountFunction,
        params: [],
      );

      return (result.first as BigInt).toInt(); // Perbaikan dilakukan di sini
    } catch (e) {
      log(e.toString());
      return 0; // Handle error dengan mengembalikan nilai default
    }
  }

  // Fungsi untuk mendapatkan detail tugas
  Future<List<dynamic>> getTask(int taskId) async {
    final getTaskFunction = _contract.function("getTask");
    final result = await _client.call(
      contract: _contract,
      function: getTaskFunction,
      params: [BigInt.from(taskId)],
    );
    return result;
  }

  Future<void> deleteTask(int index) async {
    try {
      final deleteTaskFunction = _contract.function("deleteTask");

      await _client.sendTransaction(
        _credentials,
        Transaction.callContract(
          contract: _contract,
          function: deleteTaskFunction,
          parameters: [BigInt.from(index)],
        ),
        chainId: chainId, // Pastikan chain ID sesuai
      );
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> updateTask(int index, String newTaskName, bool isCompleted) async {
    try {
      final updateTaskFunction = _contract.function("updateTask");

      await _client.sendTransaction(
        _credentials,
        Transaction.callContract(
          contract: _contract,
          function: updateTaskFunction,
          parameters: [BigInt.from(index), newTaskName, isCompleted],
        ),
        chainId: chainId, // Pastikan chain ID sesuai
      );
    } catch (e) {
      log(e.toString());
    }
  }
}
