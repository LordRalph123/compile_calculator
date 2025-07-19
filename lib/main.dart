import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Advanced Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  CalculatorScreenState createState() => CalculatorScreenState();
}

class CalculatorScreenState extends State<CalculatorScreen> {
  static const _maxDisplayLength = 12;
  String _currentInput = '0';
  String _storedValue = '0';
  String _operation = '';
  String _lastOperation = '';
  double _memoryValue = 0.0;
  bool _isNewInput = true;
  bool _showHistory = false;
  final List<String> _history = [];

  void _handleButtonPress(String buttonText) {
    setState(() {
      if (buttonText == 'C') {
        _clearAll();
      } else if (buttonText == 'CE') {
        _clearEntry();
      } else if (buttonText == '±') {
        _toggleSign();
      } else if (buttonText == '%') {
        _calculatePercentage();
      } else if (buttonText == '√') {
        _calculateSquareRoot();
      } else if (buttonText == 'MC') {
        _memoryClear();
      } else if (buttonText == 'MR') {
        _memoryRecall();
      } else if (buttonText == 'M+') {
        _memoryAdd();
      } else if (buttonText == 'M-') {
        _memorySubtract();
      } else if (buttonText == '⌫') {
        _backspace();
      } else if (buttonText == '.') {
        _addDecimal();
      } else if (buttonText == '=' ||
          buttonText == '+' ||
          buttonText == '-' ||
          buttonText == '×' ||
          buttonText == '÷') {
        _handleOperation(buttonText);
      } else if (RegExp(r'[0-9]').hasMatch(buttonText)) {
        _inputDigit(buttonText);
      }

      if (buttonText == 'H') {
        _toggleHistory();
      }
    });
  }

  void _clearAll() {
    _currentInput = '0';
    _storedValue = '0';
    _operation = '';
    _isNewInput = true;
  }

  void _clearEntry() {
    _currentInput = '0';
    _isNewInput = true;
  }

  void _toggleSign() {
    if (_currentInput != '0') {
      if (_currentInput.startsWith('-')) {
        _currentInput = _currentInput.substring(1);
      } else {
        _currentInput = '-$_currentInput';
      }
    }
  }

  void _calculatePercentage() {
    try {
      final value = double.parse(_currentInput) / 100;
      _currentInput = _formatNumber(value);
      _isNewInput = true;
    } catch (e) {
      _currentInput = 'Error';
    }
  }

  void _calculateSquareRoot() {
    try {
      final value = double.parse(_currentInput);
      if (value < 0) {
        _currentInput = 'Error';
      } else {
        _currentInput = _formatNumber(sqrt(value));
      }
      _isNewInput = true;
      _addToHistory('√($value) = $_currentInput');
    } catch (e) {
      _currentInput = 'Error';
    }
  }

  void _memoryClear() {
    _memoryValue = 0.0;
  }

  void _memoryRecall() {
    _currentInput = _formatNumber(_memoryValue);
    _isNewInput = true;
  }

  void _memoryAdd() {
    try {
      _memoryValue += double.parse(_currentInput);
    } catch (e) {
      _memoryValue = 0.0;
    }
  }

  void _memorySubtract() {
    try {
      _memoryValue -= double.parse(_currentInput);
    } catch (e) {
      _memoryValue = 0.0;
    }
  }

  void _backspace() {
    if (_currentInput.length == 1 ||
        (_currentInput.length == 2 && _currentInput.startsWith('-'))) {
      _currentInput = '0';
    } else {
      _currentInput = _currentInput.substring(0, _currentInput.length - 1);
    }
  }

  void _addDecimal() {
    if (_isNewInput) {
      _currentInput = '0.';
      _isNewInput = false;
    } else if (!_currentInput.contains('.')) {
      _currentInput += '.';
    }
  }

  void _inputDigit(String digit) {
    if (_isNewInput) {
      _currentInput = digit;
      _isNewInput = false;
    } else {
      if (_currentInput.length < _maxDisplayLength) {
        _currentInput += digit;
      }
    }
  }

  void _handleOperation(String op) {
    if (_operation.isNotEmpty && !_isNewInput) {
      _calculateResult();
    }

    if (op != '=') {
      _operation = op;
      _storedValue = _currentInput;
      _isNewInput = true;
    } else {
      _lastOperation = _operation;
      _operation = '';
    }
  }

  void _calculateResult() {
    try {
      final num1 = double.parse(_storedValue);
      final num2 = double.parse(_currentInput);
      double result = 0.0;

      switch (_operation) {
        case '+':
          result = num1 + num2;
          break;
        case '-':
          result = num1 - num2;
          break;
        case '×':
          result = num1 * num2;
          break;
        case '÷':
          if (num2 == 0) {
            _currentInput = 'Error';
            _isNewInput = true;
            _operation = '';
            return;
          }
          result = num1 / num2;
          break;
      }

      _addToHistory('$num1 $_operation $num2 = $result');
      _currentInput = _formatNumber(result);
      _storedValue = _currentInput;
      _isNewInput = true;
    } catch (e) {
      _currentInput = 'Error';
      _isNewInput = true;
      _operation = '';
    }
  }

  String _formatNumber(double value) {
    final str = value.toString();
    if (str.contains('.') && str.endsWith('0')) {
      return value.toStringAsFixed(0);
    }
    return value.toString();
  }

  void _addToHistory(String entry) {
    _history.insert(0, entry);
    if (_history.length > 5) {
      _history.removeLast();
    }
  }

  void _toggleHistory() {
    _showHistory = !_showHistory;
  }

  Widget _buildButton(String text, {Color? color, Color? textColor}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? Theme.of(context).primaryColor,
            foregroundColor: textColor ?? Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(20),
          ),
          onPressed: () => _handleButtonPress(text),
          child: Text(
            text,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Calculator'),
        actions: [
          IconButton(
            icon: Icon(_showHistory ? Icons.calculate : Icons.history),
            onPressed: () => _handleButtonPress('H'),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.all(1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (_showHistory && _history.isNotEmpty)
                  Column(
                    children:
                        _history
                            .map(
                              (entry) => Text(
                                entry,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                            .toList(),
                  ),
                Text(
                  _currentInput,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (_operation.isNotEmpty)
                  Text(
                    '$_storedValue $_operation',
                    style: const TextStyle(fontSize: 24, color: Colors.grey),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          Row(
            children: [
              _buildButton('MC', color: Colors.grey[800]),
              _buildButton('MR', color: Colors.grey[800]),
              _buildButton('M+', color: Colors.grey[800]),
              _buildButton('M-', color: Colors.grey[800]),
            ],
          ),
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    _buildButton('C', color: Colors.red),
                    _buildButton('CE', color: Colors.red),
                    _buildButton('⌫', color: Colors.orange),
                    _buildButton('÷', color: Colors.orange),
                  ],
                ),
                Row(
                  children: [
                    _buildButton('7'),
                    _buildButton('8'),
                    _buildButton('9'),
                    _buildButton('×', color: Colors.orange),
                  ],
                ),
                Row(
                  children: [
                    _buildButton('4'),
                    _buildButton('5'),
                    _buildButton('6'),
                    _buildButton('-', color: Colors.orange),
                  ],
                ),
                Row(
                  children: [
                    _buildButton('1'),
                    _buildButton('2'),
                    _buildButton('3'),
                    _buildButton('+', color: Colors.orange),
                  ],
                ),
                Row(
                  children: [
                    _buildButton('±'),
                    _buildButton('0'),
                    _buildButton('.'),
                    _buildButton('=', color: Colors.orange),
                  ],
                ),
                Row(
                  children: [
                    _buildButton('√'),
                    _buildButton('%'),
                    _buildButton(
                      _showHistory ? 'Calc' : 'Hist',
                      color: Colors.orange,
                    ),
                    _buildButton('', color: Colors.orange),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
