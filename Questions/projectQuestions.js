1.  The registration process and the project creation process both take in input (see the slides to see all of the fields).
  a) Will this input data be stored on a database?
  b) What data needs to be stored on the blockchain about:
    i) the changeMakers
    ii) the projects created by changeMakers

// 2.  Flowchart change:
//   Sponsor does not actually send ERC20 tokens to the project.
//   --Need to figure out how this will work in the smart contracts, and then update flow Flowchart

3.  Flowchart change:
  When the loan is made whole, the Conversion contract interacts with Alchemix to get the stablecoin back.

4. In what sense is ChangeDao a decentralized autonomous organization?  A lot of the control will still be held by the team behind ChangeDao.

5. Changes in ChangeDao flow slide
  a) remove erc20 token and replace with points mechanism in Exchange.sol
  b) show direct funding from sponsor to a specific project
