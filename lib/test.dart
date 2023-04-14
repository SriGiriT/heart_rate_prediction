String st =
    "Heart Rate   :84BPMBP           :108mmHgAir Humidity :85%Temperature  :98.6FSPO2         :9%" +
        "%";
void main() {
  st.replaceAll(RegExp('BPM'), ':');
  int ind = 0;
  for (String i in extractValues(st)) {
    print(ind++);
    print(i);
  }
}

List<String> extractValues(String input) {
  List<String> values = [];
  List<String> val = ["BPM", "mmHg", "%", "F", "%", "", ""];
  int ind = 0;
  String varr = val[ind];
  // Iterate over each character in the input string
  for (int i = 0; i < input.length; i++) {
    // Check if the current character is a colon
    if (input[i] == ':') {
      // Find the index of the next colon after the current position
      int endIndex = input.indexOf("$varr", i + 1);
      if (endIndex == -1) {
        // If there are no more colons, assume the remaining text is the value
        values.add(input.substring(i + 1).trim());
        break;
      } else {
        // Extract the value between the colons
        String value = input.substring(i + 1, endIndex).trim();
        values.add(value);
        i = endIndex; // Skip ahead to the next colon
      }
      varr = val[++ind];
    }
  }

  return values;
}
