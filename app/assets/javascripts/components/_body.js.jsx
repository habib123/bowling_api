var Body = React.createClass({

  getInitialState (){
    return {
      details: {
        id: 'No',
        point: 'No',
        point_by_frame: '',
        game_over: 2,
      },
      notification: ''
    }
  },


  startGame(){
    $.ajax({
        url: 'api/bowlings',
        type: 'POST',
        success:(data) =>{
          this.resetState(data.id);
          this.startInter();
        }
     });
  },

  resetState(id){
      reset_details= {
        id: id,
        point: 0,
        point_by_frame: '',
        game_over: 0,
      }
    this.setState({ details: reset_details });
    this.setState({ notification: '' });
  },

  startInter() {
    this.intervalID = setInterval(() => this.updatedDetails(), 2000);
  },

  componentWillUnmount() {
    clearInterval(this.intervalID);
  },

  updateScore(score){
    $.ajax({
        url: 'api/bowlings/'+this.state.details.id,
        type: 'PATCH',
        data: { fallen_pins: score },
        success: (data) =>{
            this.updatedDetails();
            this.clearError();
        },
        error: (request) => {
          this.setError(request);
        }
    });
  },

  updatedDetails(){
    $.ajax({
      url: 'api/bowlings/'+this.state.details.id,
      type: 'GET',
      success: (data) =>{
        this.setState({ details: data });
      },
      error: (response)=>{
        this.setError(request);
      }
    });
  },

  setError(request){
      this.setState({notification: request.responseJSON.message});
  },

  clearError(){
      this.setState({notification: ''});
  },

   render(){
      return(
          <div>
            <p>{this.state.notification}</p>
            <button onClick={this.startGame}>Start game</button>
            <Scoredetails details={this.state.details}/>
            <Throw  id={this.state.details.id} upScore={this.updateScore}/>
          </div>
      )
   }
});
