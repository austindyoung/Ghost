class Trie

  attr_reader :root
  attr_writer :root

  def initialize(root = Node.new)
    @root = root
  end

  def insert(new_word)

    if new_word.length == 1 && root.subtrees[new_word]
      child = root.subtrees[new_word].root
      child.is_word = true
      child.frequency_hash.combine(make_hash(child.word))
      child.update_parent_freq_hashes(make_hash(child.word))

    elsif new_word.length == 1
      parent_word = root.word
      new_hash = make_hash(parent_word + new_word)
      new_child = Node.new(parent_word + new_word, root, new_hash, true, {})
      root.subtrees[new_word] = Trie.new(new_child)
      new_child.update_parent_freq_hashes(new_hash)

    elsif root.subtrees[new_word[0]]
      root.subtrees[new_word[0]].insert(new_word[1..-1])

    else
      letter = new_word[0]
      new_trie = Trie.new(Node.new(root.word + letter, root, {}, false, {}))
      new_trie.insert(new_word[1..-1])
      root.subtrees[letter] = new_trie
    end
  end

  def make_hash(word)
    hash = {}
    word.chars do |letter|
      hash[letter] = hash[letter] ? hash[letter] + 1 : 1
    end
    hash
  end

  def add(letter, hash)
    hash[letter]  = hash[letter] ? hash[letter] + 1 : 1
  end

end

class Node

  attr_reader :word, :parent, :frequency_hash, :subtrees, :is_word
  attr_writer :word, :parent, :frequency_hash, :subtrees, :is_word

  def initialize(word = "", parent = nil, frequency_hash = {}, is_word = false, subtrees = {})
    @word = word
    @parent = parent
    @frequency_hash = frequency_hash
    @is_word = is_word
    @subtrees = subtrees
  end

  def update_parent_freq_hashes(new_hash)
    if parent
      parent.frequency_hash.combine(new_hash)
      parent.update_parent_freq_hashes(new_hash)
    end
  end

end

class Hash
  def combine(hash)
    hash.each do |letter, freq|
      self[letter] = (self[letter] ? self[letter] + freq : freq)
    end
  end
end
