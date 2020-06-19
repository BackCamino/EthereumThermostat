import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';

class ThermostatInteractions {
  static get contractAddress =>
      EthereumAddress.fromHex('0xB1022cE732cFb847409ACa8cf22E732A826f4dd4');

  static Web3Client get web3Client => new Web3Client(
        'https://rinkeby.infura.io/v3/2fd29e9727b04f57a7c20926b2047d5d',
        Client(),
      );

  static Future<Credentials> get credentials =>
      web3Client.credentialsFromPrivateKey(
          '0x1454196205D108917B9A92E0A24169FEB0752E967119F4DCF3B107A80F3E6600');

  static get contractAbi =>
      '[	{		"inputs": [			{				"internalType": "uint256",				"name": "num",				"type": "uint256"			}		],		"name": "store",		"outputs": [],		"stateMutability": "nonpayable",		"type": "function"	},	{		"inputs": [],		"name": "retreive",		"outputs": [			{				"internalType": "uint256",				"name": "",				"type": "uint256"			}		],		"stateMutability": "view",		"type": "function"	}]';

  static test() async {
    /*
    var apiUrl =
        'https://rinkeby.infura.io/v3/2fd29e9727b04f57a7c20926b2047d5d';

    var httpClient = new Client();
    var ethClient = new Web3Client(apiUrl, httpClient);

    var credentials = ethClient.credentialsFromPrivateKey(
        '0x1454196205D108917B9A92E0A24169FEB0752E967119F4DCF3B107A80F3E6600');

    EtherAmount balance =
        await ethClient.getBalance(await (await credentials).extractAddress());

    print(balance.getValueInUnit(EtherUnit.ether));
    */

    DeployedContract contract = DeployedContract(
      ContractAbi.fromJson(contractAbi, 'Storage'),
      contractAddress,
    );

    ContractFunction storeFunction = contract.function('store');
    ContractFunction retrieveFunction = contract.function('retreive');

    String result1 = await web3Client.sendTransaction(
      await credentials,
      Transaction.callContract(
        contract: contract,
        function: storeFunction,
        parameters: [BigInt.from(5)],
        from: await (await credentials).extractAddress(),
      ),
      fetchChainIdFromNetworkId: true,
    );

    print(result1);

    print((await web3Client.getTransactionReceipt(result1)).status);

    Future.delayed(const Duration(seconds: 15), () async {
      print((await web3Client.getTransactionReceipt(result1)).status);
    });

    var result2 = await web3Client.call(
      contract: contract,
      function: retrieveFunction,
      params: [],
    );

    print(result2);
  }
}
