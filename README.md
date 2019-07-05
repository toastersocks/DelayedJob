# DelayedJob

Run a task at a later time. Subsequent requests to run the job while there's already one scheduled will result in either the already scheduled job to be canceled or the new run to be ignored. Whether to prioritize runs scheduled for sooner or for later can be configured.

## Uses

This can be useful, for instance, if you'd like to initiate a network request as the user is typing but only if the user stops typing for at least a second in order to not fire off too many unnecessary network requests.

``` Swift

let networkRequest = DelayedJob(prioritize: .later) { networkFetcher.sendRequest(searchText) }

func editingDidChange(sender: UITextField) {
    searchText = sender.text
    networkRequest.run(withDelay: 1)
}
```
Using, the `.later` priority, If a run is requested before the existing run has fired, the previously scheduled run is canceled and the new one is scheduled. That way the network request will only actually be run when the user stops typing for more than a second.

