protocol NonceProviding {
    func makeNonce(length: Int) -> String
    func sha256(_ input: String) -> String
}

extension NonceProviding {
    func makeNonce() -> String {
        makeNonce(length: 32)
    }
}
