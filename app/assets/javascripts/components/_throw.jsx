var Throw =  React.createClass({

  updateScore(){
    var score = this.refs.score.value;
    this.props.upScore(score);
  },

  render(){
    return(
      <div>
        <input ref='score' placeholder='Enter the score'/>
        <button onClick={this.updateScore}>Submit</button>
      </div>
    )
  }
});
