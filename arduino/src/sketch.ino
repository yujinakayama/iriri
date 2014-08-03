const int kIRLEDPin = 3;
const int kSensorPin = 8;
const int kIndicatorLEDPin = 9;
const int kBufferMax = 1024;
const unsigned long kPulseEndThresholdMicros = 100000;
const unsigned long kSerialReadTimeoutMicros = 1000000;

void setup() {
  pinMode(kIRLEDPin, OUTPUT);
  pinMode(kSensorPin, INPUT);
  pinMode(kIndicatorLEDPin, OUTPUT);
  Serial.begin(9600);
}

void loop() {
  if (Serial.available()) {
    unsigned int buffer[kBufferMax] = {};
    boolean hasRead = read_signal_from_serial(buffer);
    if (hasRead) {
      send_ir(buffer);
    }
  } else {
    receive_ir();
  }
}

boolean read_signal_from_serial(unsigned int buffer[]) {
  int currentInteger = 0;
  boolean hasReadDigit = false;
  int index = 0;
  unsigned long startMicros = micros();

  while (true) {
    while (!Serial.available()) {
      if (micros() - startMicros > kSerialReadTimeoutMicros) {
        return false;
      }
    }

    int readByte = Serial.read();

    if ('0' <= readByte && readByte <= '9') {
      int readInteger = readByte - '0';
      currentInteger = (currentInteger * 10) + readInteger;
      hasReadDigit = true;
    } else if (!hasReadDigit) {
      return false;
    } else if (readByte != ',' && readByte != '\r') {
      return false;
    } else {
      buffer[index] = currentInteger;

      currentInteger = 0;
      hasReadDigit = false;
      index++;

      if (index >= kBufferMax) {
        return false;
      }

      if (readByte == '\r') {
        buffer[index] = 0; // Mark end of pulse
        break;
      }
    }
  }

  return true;
}

void send_ir(unsigned int buffer[]) {
  for (int i = 0; i < kBufferMax; i++) {
    unsigned long durationMicros = buffer[i] * 10;

    if (durationMicros == 0) {
      break;
    }

    unsigned long startMicros = micros();

    if (i % 2 == 0) {
      while (micros() - startMicros < durationMicros) {
        digitalWrite(kIRLEDPin, HIGH);
        delayMicroseconds(6);
        digitalWrite(kIRLEDPin, LOW);
        delayMicroseconds(8);
      }
    } else {
      while (micros() - startMicros < durationMicros) {};
    }
  }
}

void receive_ir() {
  boolean receiving = false;
  boolean firstSignal = true;

  // IR receiver module (PL-IRM2121-A538) returns HIGH when it's idle,
  // and returns LOW when it's receiving a IR signal.
  int currentState = HIGH;
  int lastChangeState = HIGH;

  unsigned long currentMicros = 0;
  unsigned long lastChangeMicros = 0;

  while (true) {
    currentState = digitalRead(kSensorPin);

    if (currentState == HIGH && !receiving) {
      break;
    }

    currentMicros = micros();

    if (currentState != lastChangeState) {
      if (receiving) {
        if (firstSignal) {
          firstSignal = false;
        } else {
          Serial.print(',');
        }
        // This mean duration of the previous state, not the current state.
        Serial.print((currentMicros - lastChangeMicros) / 10);
      } else {
        receiving = true;
      }

      lastChangeState = currentState;
      lastChangeMicros = currentMicros;

      digitalWrite(kIndicatorLEDPin, (currentState == LOW) ? HIGH : LOW);
    } else if ((currentMicros - lastChangeMicros) > kPulseEndThresholdMicros) {
      Serial.println();
      return;
    }
  }
}
