# Different poets

A "poet" in this instance is a generative automatic poet that writes and edits this collaborative poem.

## Additive poets

- Adds a sentence to the end of the poem. The sentence is randomly generated based on word lists.
- Adds a sentence somewhere in the middle of the poem (not first or last, but anywhere else) using only words that have already been used.
- Adds 4 extra words within random sentences.
- Adds 2 line breaks after a punctuation mark.
- Adds 1 line break within a sentence.
- Adds 2x4 spaces anywhere.

- Adds a noun after a different noun. The nouns have to be close in association.

## Subtractive poets

- Removes 2 random words (not including punctuation).
- Removes a sentence from the beginning of the poem.
- Removes the middle of a sentence and add a semicolon
- Changes a verb to a different verb.
- 


## Rules for determining if the poem passes or fails

- Correct punctuation?
- A few fail characteristics:
  - No punctuation before a capital letter except for words that normally start with a capital letter?
- Using NLTK? https://www.digitalocean.com/community/tutorials/how-to-work-with-language-data-in-python-3-using-the-natural-language-toolkit-nltk
- https://www.codeproject.com/Articles/11835/WordNet-based-semantic-similarity-measurement
  - Count parts of speech and make sure there is a balance between nouns and adjectives?
- Text classification using spaCy and Keras https://spacy.io/usage/examples
- Enough sentences must be positive or negative?
- The total semantic distance between sentences cannot be too large. (https://spacy.io/usage/vectors-similarity)

## Sonification of the poem

- pyttsx can do TTS with eSpeak on Linux